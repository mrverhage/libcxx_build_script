# This is a Python script to produce the makefile to build libc++ and libc++abi
# The script is designed to work with Mingw-w64 on a Windows platform

# Important:
# Manually edit the 4 paths below so the script can find the necessary files.
# Source file paths can be relative to the folder where this script is called
# from.
# The makefile is also put in the folder where this script is called from.
# This affects how include folders and library folders needs to be specified.
# 
# Also set configurations below. Like if threads and exceptions should be 
# enabled.
# The file <libc++abi source folder>/src/CMakeLists shows what needs to be
# done to comply with configuration settings like this. This should be put
# into this Python script.
libcxx_src_path = "../../../../libcxx/src"
libcxx_inc_path = "../../../../libcxx/include"
libcxxabi_src_path = "../../../../libcxxabi/src"
libcxxabi_inc_path = "../../../../libcxxabi/include"
enable_exceptions = True # this is applied to libc++ and libc++abi
enable_threads = True # Currently no decision has to be made

import os, glob
import textwrap

# This function provides text wrapping of the strings that need to be written
# to the makefile
def apply_makefile_textwrapping( s, mf ): # mf stands for makefile
  lines = textwrap.wrap( 
    s,
    80 - 1,                   # - 1 is to have room to write \ at end
    break_on_hyphens=False )  # a thing such as -Wno-error should be on the
    # same line

  i = 0
  for line in lines:
    i = i + 1
    mf.write( line )
    if i < len(lines): # the last line doesn't need \
      mf.write( "\\" )
    mf.write( "\r\n" )
  return;

# This section provide a list of source filenames without extension
# So: 'cxa_vector.cpp' becomes 'cxa_vector' 
cxxabi_src_files = []
for cxxabi_src_file in glob.glob( os.path.join( libcxxabi_src_path, "*.cpp" ) ):
  if os.path.isfile( cxxabi_src_file ):
    base_src_file = os.path.basename( cxxabi_src_file )
    if enable_exceptions:
      if base_src_file == "cxa_noexception.cpp": continue # abandon this file
    else:
      if ( base_src_file == "cxa_exception.cpp" or
           base_src_file == "cxa_personality.cpp" ): continue
    cxxabi_src_files.append(
      os.path.splitext( base_src_file )[0] )
if len(cxxabi_src_files) == 0:
  print "No cpp source files found in folder:"
  print os.getcwd() + "/" + libcxxsrc_path
  sys.exit( 1 )

# The same but now for libcxx
#
cxx_src_files = []
for cxx_src_file in glob.glob( os.path.join( libcxx_src_path, "*.cpp" ) ):
  if os.path.isfile( cxx_src_file ):
    cxx_src_files.append(
      os.path.splitext( os.path.basename( cxx_src_file ) )[0] )
if len(cxx_src_files) == 0:
  print "No cpp source files found in folder:"
  print os.getcwd() + "/" + libcxx_path
  sys.exit( 1 )

# Add win32 support files too
win32_support_rel_path = "support/win32"
libcxx_src_win32_support = os.path.join(
  libcxx_src_path, win32_support_rel_path ).replace("\\","/")

for cxx_src_file in glob.glob( 
    os.path.join( libcxx_src_win32_support, "*.cpp" ) ):
  if os.path.isfile( cxx_src_file ):
    cxx_src_files.append(
      os.path.join( 
        win32_support_rel_path,
        os.path.splitext( os.path.basename( cxx_src_file ) )[0]
        ).replace("\\","/") )

mf = open( "libcxx_build.mak", "wb" ) # mf stands for makefile

s = ("# This makefile is build with python script:\r\n" + 
"# " + __file__ + "\r\n" )
mf.write( s )
mf.write( "\r\n" )

s = ("LIBCXX_SRC_FOLDER = " + libcxx_src_path + "\r\n" +
"LIBCXXABI_SRC_FOLDER = " + libcxxabi_src_path + "\r\n" +
"LIBCXX_INC = -I\"" + libcxx_inc_path + "\"\r\n" +
"LIBCXXABI_INC = -I\"" + libcxxabi_inc_path + "\"\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ("LIBSWIN = -l:libkernel32.a -l:libuser32.a -l:libshell32.a" +
" -l:libadvapi32.a -l:libws2_32.a -l:liboleaut32.a -l:libimm32.a" +
" -l:libwinmm.a -l:libole32.a -l:libuuid.a -l:libopengl32.a -l:libole32.a" +
" -l:libgdi32.a")
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

s = ("LIBSMINGW = -l:libmingw32.a -l:libgcc.a -l:libgcc_eh.a -l:libmoldname.a" +
" -l:libmingwex.a -l:libmsvcrt.a -l:libadvapi32.a -l:libshell32.a" +
" -l:libuser32.a -l:libkernel32.a -l:libiconv.a -l:libmingw32.a -l:libgcc.a" +
" -l:libgcc_eh.a -l:libmoldname.a -l:libmingwex.a -l:libmsvcrt.a")
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

# LIBCXXABI_FLAGS section
s = ("# Lookup the file flags.make\r\n" +
"# in folder <libcxxabi build path>\src\CMakeFiles\cxxabi_objects.dir\r\n" +
"# to see what LIBCXXABI_FLAGS needs to be\r\n")
mf.write( s )
s = ("LIBCXXABI_FLAGS = -nostdinc++ -std=c++11 -O3" +
" -Werror=return-type -W -Wall -Wchar-subscripts -Wconversion" +
" -Wmissing-braces -Wunused-function -Wshadow -Wsign-compare" +
" -Wsign-conversion -Wstrict-aliasing=2 -Wstrict-overflow=4" +
" -Wunused-parameter -Wunused-variable -Wwrite-strings -Wundef -Wno-error" +
" -pedantic -fstrict-aliasing -funwind-tables")
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

# LIBCXX_FLAGS section
s = ("# As noted before check flags.make in folder:\r\n" +
"# <libcxx build path>\src\CMakeFiles\cxxabi_objects.dir but also:\r\n" +
"# <libcxx build path>\src\CMakeFiles\cxxabi_shared.dir and\r\n" +
"# <libcxx build path>\__config_site include file to see what\r\n" +
"# LIBCXX_FLAGS and LIBCXX_DEFINES needs to be\r\n" +
"# also read UsingLibcxx.rst for guidelines regarding defines and flags\r\n")
mf.write( s )
s = ("LIBCXX_FLAGS = -nostdinc++ -std=c++11 -O3" +
" -fvisibility-inlines-hidden" +
" -Wall -Wextra -W -Wwrite-strings -Wno-unused-parameter -Wno-long-long" +
" -Werror=return-type -Wextra-semi -Wno-literal-suffix -Wno-c++14-compat" +
" -Wno-noexcept-type -Wno-error")
if not enable_exceptions:
  s += " -fno-exceptions"
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

# LIBCXXABI_DEFINES section
# edits:
# TODO if needed consider set back 
# -D_LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS
# added -DLIBCXX_BUILDING_LIBCXXABI
# removed -U_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS
# removed -Dcxxabi_shared_EXPORTS
s = ("# As for LIBCXXABI_FLAGS, the same file flags.make also specify the\r\n" +
"# defines. During compilation the include files of libc++ are also\r\n" +
"# processed, therefore LIBCXXABI_DEFINES also contain defines for libc++\r\n")
mf.write( s )
s = ("LIBCXXABI_DEFINES = -DNDEBUG" +
" -D_LIBCXXABI_BUILDING_LIBRARY" +
" -DLIBCXX_BUILDING_LIBCXXABI -D_WIN32_WINNT=0x0600" + 
" -D_LIBCPP_HAS_THREAD_API_WIN32 -D_LIBCPP_DISABLE_EXTERN_TEMPLATE")
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

# LIBCXX_DEFINES section
# TODO consider removing -D_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER
# edits:
# Important: Ensure that -DLIBCXX_BUILDING_LIBCXXABI does not have that
# underscore, yes very non-uniform
# removed: -D_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER <-- improvement on 
# number of undefined references
# removed -Dcxx_shared_EXPORTS
s = ("LIBCXX_DEFINES = -DNDEBUG -D_LIBCPP_BUILDING_LIBRARY" +
" -DLIBCXX_BUILDING_LIBCXXABI -D_WIN32_WINNT=0x0600" +
" -D_LIBCPP_HAS_THREAD_API_WIN32")
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

cxx_obj_folder = "cxx_obj"
cxxabi_obj_folder = "cxxabi_obj"

s = "LIBCXXABI_OBJ_FILES = $(addprefix " + cxxabi_obj_folder + "/,"
for cxxabi_src_file in cxxabi_src_files:
  s += " " + cxxabi_src_file + ".o"
s += ")"
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

s = "LIBCXX_OBJ_FILES = $(addprefix " + cxx_obj_folder + "/,"
for cxx_src_file in cxx_src_files:
  s += " " + cxx_src_file + ".o"
s += ")"
apply_makefile_textwrapping( s, mf )
mf.write( "\r\n" )

cxxabi_import_library = "libc++abi.dll.a"
cxxabi_archive_library = "cxxabi_objects.a"
cxxabi_dll = "libc++abi.dll"
cxx_import_library = "libc++.dll.a"
cxx_archive_library = "cxx_objects.a"
cxx_dll = "libc++.dll"

s = ("all: make_folders " +
cxxabi_obj_folder + "/" + cxxabi_dll + " " +
cxx_obj_folder + "/" + cxx_dll + "\r\n")
mf.write( s )
mf.write( "\r\n" )

s = (".PHONY: make_folders\r\n" +
"make_folders:\r\n" +
"\tif not exist " + cxx_obj_folder + " mkdir " + cxx_obj_folder + "\r\n" +
"\tif not exist " + cxx_obj_folder + "\\" + 
win32_support_rel_path.replace("/","\\") + " mkdir " + cxx_obj_folder + "\\" + 
win32_support_rel_path.replace("/","\\") + " \r\n" +
"\tif not exist " + cxxabi_obj_folder + " mkdir " + cxxabi_obj_folder + "\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ("#\r\n# ** Section for final library creation **\r\n#\r\n")
mf.write( s )

s = ( cxx_obj_folder + "/" + cxx_dll + " : " +
cxx_obj_folder + "/" + cxx_archive_library + " " +
cxxabi_obj_folder + "/" + cxxabi_import_library + "\r\n" +
"\tg++ -shared -nodefaultlibs -L" + cxxabi_obj_folder + " \\\r\n" +
"\t-Wl,--whole-archive " + cxx_obj_folder + "/" + cxx_archive_library +
" \\\r\n" +
"\t-Wl,--no-whole-archive \\\r\n" +
"\t-l:" + cxxabi_import_library + " \\\r\n" +
"\t$(LIBSMINGW) $(LIBSWIN) \\\r\n" +
"\t-Wl,--major-image-version,1,--minor-image-version,0 \\\r\n" +
"\t-o " + cxx_obj_folder + "/" + cxx_dll + "\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ( cxxabi_obj_folder + "/" + cxxabi_dll + " : " +
cxxabi_obj_folder + "/" + cxxabi_archive_library + " " +
cxx_obj_folder + "/" + cxx_import_library + "\r\n" +
"\tg++ -shared -nodefaultlibs -L" + cxx_obj_folder + " \\\r\n" +
# "\t-Wl,--start-group \\\r\n" +
"\t-Wl,--whole-archive " + cxxabi_obj_folder + "/" + cxxabi_archive_library +
" \\\r\n" +
"\t-Wl,--no-whole-archive \\\r\n" +
"\t-l:" + cxx_import_library + " \\\r\n" +
# "\t-Wl,--end-group \\\r\n"
"\t$(LIBSMINGW) $(LIBSWIN) \\\r\n"
"\t-Wl,--major-image-version,1,--minor-image-version,0 \\\r\n" +
"\t-o " + cxxabi_obj_folder + "/" + cxxabi_dll + "\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ( cxxabi_obj_folder + "/" + cxxabi_import_library + " : " +
cxxabi_obj_folder + "/" +  cxxabi_archive_library + "\r\n" +
"\tdlltool --dllname " + cxxabi_dll + " \\\r\n" +
"\t--output-lib " + cxxabi_obj_folder + "/" + cxxabi_import_library +
" \\\r\n" +
"\t--output-exp exports_cxxabi.txt " + cxxabi_obj_folder + "/" +
cxxabi_archive_library + "\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ( cxxabi_obj_folder + "/" + cxxabi_archive_library + " : " +
"$(LIBCXXABI_OBJ_FILES)\r\n" +
"\tar rc " + cxxabi_obj_folder + "/" + cxxabi_archive_library + 
" $(LIBCXXABI_OBJ_FILES)\r\n" )
mf.write( s )
mf.write( "\r\n" )

s = ( cxx_obj_folder + "/" + cxx_import_library + " : " +
cxx_obj_folder + "/" +  cxx_archive_library + "\r\n" +
"\tdlltool --dllname " + cxx_dll + " \\\r\n" +
"\t--output-lib " + cxx_obj_folder + "/" + cxx_import_library + " \\\r\n" +
"\t--output-exp exports_cxx.txt " + cxx_obj_folder + "/" + cxx_archive_library +
"\r\n")
mf.write( s )
mf.write( "\r\n" )

s = ( cxx_obj_folder + "/" + cxx_archive_library + " : " +
"$(LIBCXX_OBJ_FILES)\r\n" +
"\tar rc " + cxx_obj_folder + "/" + cxx_archive_library + 
" $(LIBCXX_OBJ_FILES)\r\n" )
mf.write( s )
mf.write( "\r\n" )

s = ("#\r\n# ** Section to compile LIBCXXABI sources **\r\n#\r\n")
mf.write( s )
for cxxabi_src_file in cxxabi_src_files:
  s = ( cxxabi_obj_folder + "/" + cxxabi_src_file + ".o : \\\r\n" +
  "$(LIBCXXABI_SRC_FOLDER)/" + cxxabi_src_file + ".cpp\r\n" +
  "\tg++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \\\r\n" + 
  "\t$(LIBCXX_INC) $(LIBCXXABI_INC) \\\r\n" +
  "\t$(LIBCXXABI_SRC_FOLDER)/" + cxxabi_src_file + ".cpp \\\r\n" +
  "\t-o " + cxxabi_obj_folder + "/" + cxxabi_src_file + ".o\r\n")
  mf.write( s )
  mf.write( "\r\n" )

s = ("#\r\n# ** Section to compile LIBCXX sources **\r\n#\r\n")
mf.write( s )
for cxx_src_file in cxx_src_files:
  s = ( cxx_obj_folder + "/" + cxx_src_file + ".o : \\\r\n" +
  "$(LIBCXX_SRC_FOLDER)/" + cxx_src_file + ".cpp\r\n" +
  "\tg++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \\\r\n" + 
  "\t$(LIBCXX_INC) $(LIBCXXABI_INC) \\\r\n" +
  "\t$(LIBCXX_SRC_FOLDER)/" + cxx_src_file + ".cpp \\\r\n" +
  "\t-o " + cxx_obj_folder + "/" + cxx_src_file + ".o\r\n")
  mf.write( s )
  mf.write( "\r\n" )

s = ("clean:\r\n" +
"\trd /s /q " + cxx_obj_folder + "\r\n" + 
"\trd /s /q " + cxxabi_obj_folder + "\r\n")
mf.write( s )

mf.close()