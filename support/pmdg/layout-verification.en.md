Independent SDK layout verification
===================================

The generated layout was checked against ctypes native structure layout and
compiled by the installed MSFS 2024 SDK clang-cl compiler using /Zp8.
All static_assert checks passed: sizeof(PMDG_NG3_Data)=916,
sizeof(PMDG_NG3_CDU_Screen)=1009, and every original data member offset.

Header SHA-256: 2ccc93f1d04bd52185a4bd04ed3e7eebf183059207ad4a27f481d1ea298e2609
