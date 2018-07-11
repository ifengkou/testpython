CMake Error at cmake/readline.cmake:66 (MESSAGE):
  Curses library not found.  Please install appropriate package,

      remove CMakeCache.txt and rerun cmake.On Debian/Ubuntu, package name is libncurses5-dev, on Redhat and derivates it is ncurses-devel.
Call Stack (most recent call first):
  cmake/readline.cmake:190 (FIND_CURSES)
  cmake/readline.cmake:264 (FIND_SYSTEM_READLINE)
  CMakeLists.txt:538 (MYSQL_CHECK_EDITLINE)

yum install ncurses-devel

CMake Error at cmake/readline.cmake:266 (MESSAGE):
  Cannot find system readline libraries.
Call Stack (most recent call first):
  CMakeLists.txt:538 (MYSQL_CHECK_EDITLINE)

yum install -y readline-devel

CMake Error at plugin/keyring_vault/CMakeLists.txt:18 (message):
  Not building keyring_vault, could not find library: CURL
Call Stack (most recent call first):
  plugin/keyring_vault/CMakeLists.txt:23 (CHECK_IF_LIB_FOUND)

  yum install libcurl-devel