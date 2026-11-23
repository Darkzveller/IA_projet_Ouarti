import logging
import mmap
import struct
import time
import numpy as np

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

IMAGE_SHM_TAG = "Local\\DualBufferImage"
HEADER_FMT = "<IQ"       # active_index (uint32), global_seq (uint64)
SLOT_META_FMT = "<Qd"    # slot_seq (uint64), captured_at (float64)
HEADER_SIZE = struct.calcsize(HEADER_FMT)
SLOT_META_SIZE = struct.calcsize(SLOT_META_FMT)


class GrabberSharedMemoryDualBuffer:
    """Shared Memory Dual Buffer supporting grayscale/BGR images with timestamps."""

    def __init__(self, shm_image_width, shm_image_height, color_mode):
        self.shm_image_width = int(shm_image_width)
        self.shm_image_height = int(shm_image_height)

        mode = str(color_mode).lower()
        if mode == "bgr":
            self.channels = 3
        elif mode == "gray":
            self.channels = 1
        else:
            raise ValueError(f"Invalid color_mode. Choose 'gray' or 'bgr'. Got: {color_mode}")

        self.image_size = self.shm_image_width * self.shm_image_height * self.channels
        self.slot_size = SLOT_META_SIZE + self.image_size
        self.dual_shm_size = HEADER_SIZE + 2 * self.slot_size
        self.dual_shm = mmap.mmap(-1, self.dual_shm_size, tagname=IMAGE_SHM_TAG)

    def _read_header(self):
        self.dual_shm.seek(0)
        raw = self.dual_shm.read(HEADER_SIZE)
        if len(raw) < HEADER_SIZE:
            return 0, 0
        active_index, seq = struct.unpack(HEADER_FMT, raw)
        if active_index not in (0, 1):
            active_index = 0
        return active_index, seq

    def _slot_offset(self, index):
        return HEADER_SIZE + index * self.slot_size

    def _reshape(self, img_bytes):
        arr = np.frombuffer(img_bytes, dtype=np.uint8)
        if self.channels == 1:
            return arr.reshape((self.shm_image_height, self.shm_image_width)).copy()
        return arr.reshape((self.shm_image_height, self.shm_image_width, self.channels)).copy()

    def read_active_index(self):
        active_index, _ = self._read_header()
        return active_index

    def get_timed_image(self, max_retries=5):
        """Returns (seq, captured_at, img_array) with lock-free consistency check."""
        for _ in range(max_retries):
            idx1, seq1 = self._read_header()
            self.dual_shm.seek(self._slot_offset(idx1))
            meta_bytes = self.dual_shm.read(SLOT_META_SIZE)
            img_bytes = self.dual_shm.read(self.image_size)
            idx2, seq2 = self._read_header()

            if idx1 == idx2 and seq1 == seq2:
                slot_seq, captured_at = struct.unpack(SLOT_META_FMT, meta_bytes)
                if seq1 == slot_seq:
                    return int(slot_seq), float(captured_at), self._reshape(img_bytes)
            time.sleep(0.001)
        raise RuntimeError("No stable timestamped camera frame")

    def get_active_image(self):
        """Backward-compatible reader returning (active_index, img_bytes, img_array)."""
        active_index, _ = self._read_header()
        self.dual_shm.seek(self._slot_offset(active_index) + SLOT_META_SIZE)
        img_bytes = self.dual_shm.read(self.image_size)
        return active_index, img_bytes, self._reshape(img_bytes)

    def write_image(self, image_bytes, captured_at=None):
        """Writes image bytes + timestamp into the inactive slot and toggles active_index."""
        if len(image_bytes) > self.image_size:
            image_bytes = image_bytes[:self.image_size]
        elif len(image_bytes) < self.image_size:
            image_bytes += b"\x00" * (self.image_size - len(image_bytes))

        ts = float(time.time() if captured_at is None else captured_at)
        active_index, seq = self._read_header()
        new_index = 1 - active_index
        new_seq = seq + 1

        self.dual_shm.seek(self._slot_offset(new_index))
        self.dual_shm.write(struct.pack(SLOT_META_FMT, new_seq, ts))
        self.dual_shm.write(image_bytes)

        self.dual_shm.seek(0)
        self.dual_shm.write(struct.pack(HEADER_FMT, new_index, new_seq))
        self.dual_shm.flush()

    def close(self):
        if getattr(self, "dual_shm", None) is not None:
            self.dual_shm.close()
            self.dual_shm = None