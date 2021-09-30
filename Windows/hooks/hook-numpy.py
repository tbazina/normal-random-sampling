from PyInstaller import log as logging
from PyInstaller import compat
from os import listdir

mkldir = compat.base_prefix + "/Library/bin"
logger = logging.getLogger(__name__)
logger.info("MKL installed as part of numpy, importing that!")
binaries = [(mkldir + "/" + mkl, '.') for mkl in listdir(mkldir) if
    (mkl.endswith('mkl_scalapack_ilp64.dll') or
     mkl.endswith('mkl_cdft_core.dll') or mkl.endswith('mkl_intel_ilp64.dll') or
     mkl.endswith('mkl_intel_thread.dll') or mkl.endswith('mkl_core.dll') or
     mkl.endswith('mkl_blacs_ilp64.dll') or mkl.endswith('impi.dll') or
     mkl.endswith('libiomp5md.dll') or mkl.endswith('mkl_avx2.dll') or
     mkl.endswith('mkl_def.dll') or mkl.endswith('mkl_vml_avx2.dll') or
     mkl.endswith('mkl_vml_def.dll'))
            ]

