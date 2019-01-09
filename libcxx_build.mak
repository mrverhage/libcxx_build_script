# This makefile is build with python script:
# C:\dev\mydesign\SW\python\libcxx_build_script\libcxx_build.py

LIBCXX_SRC_FOLDER = ../../../../libcxx/src
LIBCXXABI_SRC_FOLDER = ../../../../libcxxabi/src
LIBCXX_INC = -I"../../../../libcxx/include"
LIBCXXABI_INC = -I"../../../../libcxxabi/include"

LIBSWIN = -l:libkernel32.a -l:libuser32.a -l:libshell32.a -l:libadvapi32.a\
-l:libws2_32.a -l:liboleaut32.a -l:libimm32.a -l:libwinmm.a -l:libole32.a\
-l:libuuid.a -l:libopengl32.a -l:libole32.a -l:libgdi32.a

LIBSMINGW = -l:libmingw32.a -l:libgcc.a -l:libgcc_eh.a -l:libmoldname.a\
-l:libmingwex.a -l:libmsvcrt.a -l:libadvapi32.a -l:libshell32.a -l:libuser32.a\
-l:libkernel32.a -l:libiconv.a -l:libmingw32.a -l:libgcc.a -l:libgcc_eh.a\
-l:libmoldname.a -l:libmingwex.a -l:libmsvcrt.a

# Lookup the file flags.make
# in folder <libcxxabi build path>\src\CMakeFiles\cxxabi_objects.dir
# to see what LIBCXXABI_FLAGS needs to be
LIBCXXABI_FLAGS = -nostdinc++ -std=c++11 -O3 -Werror=return-type -W -Wall\
-Wchar-subscripts -Wconversion -Wmissing-braces -Wunused-function -Wshadow\
-Wsign-compare -Wsign-conversion -Wstrict-aliasing=2 -Wstrict-overflow=4\
-Wunused-parameter -Wunused-variable -Wwrite-strings -Wundef -Wno-error\
-pedantic -fstrict-aliasing -funwind-tables

# As noted before check flags.make in folder:
# <libcxx build path>\src\CMakeFiles\cxxabi_objects.dir but also:
# <libcxx build path>\src\CMakeFiles\cxxabi_shared.dir and
# <libcxx build path>\__config_site include file to see what
# LIBCXX_FLAGS and LIBCXX_DEFINES needs to be
# also read UsingLibcxx.rst for guidelines regarding defines and flags
LIBCXX_FLAGS = -nostdinc++ -std=c++11 -O3 -fvisibility-inlines-hidden -Wall\
-Wextra -W -Wwrite-strings -Wno-unused-parameter -Wno-long-long\
-Werror=return-type -Wextra-semi -Wno-literal-suffix -Wno-c++14-compat\
-Wno-noexcept-type -Wno-error

# As for LIBCXXABI_FLAGS, the same file flags.make also specify the
# defines. During compilation the include files of libc++ are also
# processed, therefore LIBCXXABI_DEFINES also contain defines for libc++
LIBCXXABI_DEFINES = -DNDEBUG -D_LIBCXXABI_BUILDING_LIBRARY\
-DLIBCXX_BUILDING_LIBCXXABI -D_WIN32_WINNT=0x0600\
-D_LIBCPP_HAS_THREAD_API_WIN32 -D_LIBCPP_DISABLE_EXTERN_TEMPLATE

LIBCXX_DEFINES = -DNDEBUG -D_LIBCPP_BUILDING_LIBRARY\
-DLIBCXX_BUILDING_LIBCXXABI -D_WIN32_WINNT=0x0600\
-D_LIBCPP_HAS_THREAD_API_WIN32

LIBCXXABI_OBJ_FILES = $(addprefix cxxabi_obj/, abort_message.o\
cxa_aux_runtime.o cxa_default_handlers.o cxa_demangle.o cxa_exception.o\
cxa_exception_storage.o cxa_guard.o cxa_handlers.o cxa_personality.o\
cxa_thread_atexit.o cxa_unexpected.o cxa_vector.o cxa_virtual.o\
fallback_malloc.o private_typeinfo.o stdlib_exception.o stdlib_new_delete.o\
stdlib_stdexcept.o stdlib_typeinfo.o)

LIBCXX_OBJ_FILES = $(addprefix cxx_obj/, algorithm.o any.o bind.o charconv.o\
chrono.o condition_variable.o debug.o exception.o functional.o future.o hash.o\
ios.o iostream.o locale.o memory.o mutex.o new.o optional.o random.o regex.o\
shared_mutex.o stdexcept.o string.o strstream.o system_error.o thread.o\
typeinfo.o utility.o valarray.o variant.o vector.o support/win32/locale_win32.o\
support/win32/support.o support/win32/thread_win32.o)

all: make_folders cxxabi_obj/libc++abi.dll cxx_obj/libc++.dll

.PHONY: make_folders
make_folders:
	if not exist cxx_obj mkdir cxx_obj
	if not exist cxx_obj\support\win32 mkdir cxx_obj\support\win32 
	if not exist cxxabi_obj mkdir cxxabi_obj

#
# ** Section for final library creation **
#
cxx_obj/libc++.dll : cxx_obj/cxx_objects.a cxxabi_obj/libc++abi.dll.a
	g++ -shared -nodefaultlibs -Lcxxabi_obj \
	-Wl,--whole-archive cxx_obj/cxx_objects.a \
	-Wl,--no-whole-archive \
	-l:libc++abi.dll.a \
	$(LIBSMINGW) $(LIBSWIN) \
	-Wl,--major-image-version,1,--minor-image-version,0 \
	-o cxx_obj/libc++.dll

cxxabi_obj/libc++abi.dll : cxxabi_obj/cxxabi_objects.a cxx_obj/libc++.dll.a
	g++ -shared -nodefaultlibs -Lcxx_obj \
	-Wl,--whole-archive cxxabi_obj/cxxabi_objects.a \
	-Wl,--no-whole-archive \
	-l:libc++.dll.a \
	$(LIBSMINGW) $(LIBSWIN) \
	-Wl,--major-image-version,1,--minor-image-version,0 \
	-o cxxabi_obj/libc++abi.dll

cxxabi_obj/libc++abi.dll.a : cxxabi_obj/cxxabi_objects.a
	dlltool --dllname libc++abi.dll \
	--output-lib cxxabi_obj/libc++abi.dll.a \
	--output-exp exports_cxxabi.txt cxxabi_obj/cxxabi_objects.a

cxxabi_obj/cxxabi_objects.a : $(LIBCXXABI_OBJ_FILES)
	ar rc cxxabi_obj/cxxabi_objects.a $(LIBCXXABI_OBJ_FILES)

cxx_obj/libc++.dll.a : cxx_obj/cxx_objects.a
	dlltool --dllname libc++.dll \
	--output-lib cxx_obj/libc++.dll.a \
	--output-exp exports_cxx.txt cxx_obj/cxx_objects.a

cxx_obj/cxx_objects.a : $(LIBCXX_OBJ_FILES)
	ar rc cxx_obj/cxx_objects.a $(LIBCXX_OBJ_FILES)

#
# ** Section to compile LIBCXXABI sources **
#
cxxabi_obj/abort_message.o : \
$(LIBCXXABI_SRC_FOLDER)/abort_message.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/abort_message.cpp \
	-o cxxabi_obj/abort_message.o

cxxabi_obj/cxa_aux_runtime.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_aux_runtime.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_aux_runtime.cpp \
	-o cxxabi_obj/cxa_aux_runtime.o

cxxabi_obj/cxa_default_handlers.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_default_handlers.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_default_handlers.cpp \
	-o cxxabi_obj/cxa_default_handlers.o

cxxabi_obj/cxa_demangle.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_demangle.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_demangle.cpp \
	-o cxxabi_obj/cxa_demangle.o

cxxabi_obj/cxa_exception.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_exception.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_exception.cpp \
	-o cxxabi_obj/cxa_exception.o

cxxabi_obj/cxa_exception_storage.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_exception_storage.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_exception_storage.cpp \
	-o cxxabi_obj/cxa_exception_storage.o

cxxabi_obj/cxa_guard.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_guard.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_guard.cpp \
	-o cxxabi_obj/cxa_guard.o

cxxabi_obj/cxa_handlers.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_handlers.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_handlers.cpp \
	-o cxxabi_obj/cxa_handlers.o

cxxabi_obj/cxa_personality.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_personality.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_personality.cpp \
	-o cxxabi_obj/cxa_personality.o

cxxabi_obj/cxa_thread_atexit.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_thread_atexit.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_thread_atexit.cpp \
	-o cxxabi_obj/cxa_thread_atexit.o

cxxabi_obj/cxa_unexpected.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_unexpected.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_unexpected.cpp \
	-o cxxabi_obj/cxa_unexpected.o

cxxabi_obj/cxa_vector.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_vector.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_vector.cpp \
	-o cxxabi_obj/cxa_vector.o

cxxabi_obj/cxa_virtual.o : \
$(LIBCXXABI_SRC_FOLDER)/cxa_virtual.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/cxa_virtual.cpp \
	-o cxxabi_obj/cxa_virtual.o

cxxabi_obj/fallback_malloc.o : \
$(LIBCXXABI_SRC_FOLDER)/fallback_malloc.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/fallback_malloc.cpp \
	-o cxxabi_obj/fallback_malloc.o

cxxabi_obj/private_typeinfo.o : \
$(LIBCXXABI_SRC_FOLDER)/private_typeinfo.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/private_typeinfo.cpp \
	-o cxxabi_obj/private_typeinfo.o

cxxabi_obj/stdlib_exception.o : \
$(LIBCXXABI_SRC_FOLDER)/stdlib_exception.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/stdlib_exception.cpp \
	-o cxxabi_obj/stdlib_exception.o

cxxabi_obj/stdlib_new_delete.o : \
$(LIBCXXABI_SRC_FOLDER)/stdlib_new_delete.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/stdlib_new_delete.cpp \
	-o cxxabi_obj/stdlib_new_delete.o

cxxabi_obj/stdlib_stdexcept.o : \
$(LIBCXXABI_SRC_FOLDER)/stdlib_stdexcept.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/stdlib_stdexcept.cpp \
	-o cxxabi_obj/stdlib_stdexcept.o

cxxabi_obj/stdlib_typeinfo.o : \
$(LIBCXXABI_SRC_FOLDER)/stdlib_typeinfo.cpp
	g++ -c $(LIBCXXABI_FLAGS) $(LIBCXXABI_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXXABI_SRC_FOLDER)/stdlib_typeinfo.cpp \
	-o cxxabi_obj/stdlib_typeinfo.o

#
# ** Section to compile LIBCXX sources **
#
cxx_obj/algorithm.o : \
$(LIBCXX_SRC_FOLDER)/algorithm.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/algorithm.cpp \
	-o cxx_obj/algorithm.o

cxx_obj/any.o : \
$(LIBCXX_SRC_FOLDER)/any.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/any.cpp \
	-o cxx_obj/any.o

cxx_obj/bind.o : \
$(LIBCXX_SRC_FOLDER)/bind.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/bind.cpp \
	-o cxx_obj/bind.o

cxx_obj/charconv.o : \
$(LIBCXX_SRC_FOLDER)/charconv.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/charconv.cpp \
	-o cxx_obj/charconv.o

cxx_obj/chrono.o : \
$(LIBCXX_SRC_FOLDER)/chrono.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/chrono.cpp \
	-o cxx_obj/chrono.o

cxx_obj/condition_variable.o : \
$(LIBCXX_SRC_FOLDER)/condition_variable.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/condition_variable.cpp \
	-o cxx_obj/condition_variable.o

cxx_obj/debug.o : \
$(LIBCXX_SRC_FOLDER)/debug.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/debug.cpp \
	-o cxx_obj/debug.o

cxx_obj/exception.o : \
$(LIBCXX_SRC_FOLDER)/exception.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/exception.cpp \
	-o cxx_obj/exception.o

cxx_obj/functional.o : \
$(LIBCXX_SRC_FOLDER)/functional.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/functional.cpp \
	-o cxx_obj/functional.o

cxx_obj/future.o : \
$(LIBCXX_SRC_FOLDER)/future.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/future.cpp \
	-o cxx_obj/future.o

cxx_obj/hash.o : \
$(LIBCXX_SRC_FOLDER)/hash.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/hash.cpp \
	-o cxx_obj/hash.o

cxx_obj/ios.o : \
$(LIBCXX_SRC_FOLDER)/ios.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/ios.cpp \
	-o cxx_obj/ios.o

cxx_obj/iostream.o : \
$(LIBCXX_SRC_FOLDER)/iostream.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/iostream.cpp \
	-o cxx_obj/iostream.o

cxx_obj/locale.o : \
$(LIBCXX_SRC_FOLDER)/locale.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/locale.cpp \
	-o cxx_obj/locale.o

cxx_obj/memory.o : \
$(LIBCXX_SRC_FOLDER)/memory.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/memory.cpp \
	-o cxx_obj/memory.o

cxx_obj/mutex.o : \
$(LIBCXX_SRC_FOLDER)/mutex.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/mutex.cpp \
	-o cxx_obj/mutex.o

cxx_obj/new.o : \
$(LIBCXX_SRC_FOLDER)/new.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/new.cpp \
	-o cxx_obj/new.o

cxx_obj/optional.o : \
$(LIBCXX_SRC_FOLDER)/optional.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/optional.cpp \
	-o cxx_obj/optional.o

cxx_obj/random.o : \
$(LIBCXX_SRC_FOLDER)/random.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/random.cpp \
	-o cxx_obj/random.o

cxx_obj/regex.o : \
$(LIBCXX_SRC_FOLDER)/regex.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/regex.cpp \
	-o cxx_obj/regex.o

cxx_obj/shared_mutex.o : \
$(LIBCXX_SRC_FOLDER)/shared_mutex.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/shared_mutex.cpp \
	-o cxx_obj/shared_mutex.o

cxx_obj/stdexcept.o : \
$(LIBCXX_SRC_FOLDER)/stdexcept.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/stdexcept.cpp \
	-o cxx_obj/stdexcept.o

cxx_obj/string.o : \
$(LIBCXX_SRC_FOLDER)/string.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/string.cpp \
	-o cxx_obj/string.o

cxx_obj/strstream.o : \
$(LIBCXX_SRC_FOLDER)/strstream.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/strstream.cpp \
	-o cxx_obj/strstream.o

cxx_obj/system_error.o : \
$(LIBCXX_SRC_FOLDER)/system_error.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/system_error.cpp \
	-o cxx_obj/system_error.o

cxx_obj/thread.o : \
$(LIBCXX_SRC_FOLDER)/thread.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/thread.cpp \
	-o cxx_obj/thread.o

cxx_obj/typeinfo.o : \
$(LIBCXX_SRC_FOLDER)/typeinfo.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/typeinfo.cpp \
	-o cxx_obj/typeinfo.o

cxx_obj/utility.o : \
$(LIBCXX_SRC_FOLDER)/utility.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/utility.cpp \
	-o cxx_obj/utility.o

cxx_obj/valarray.o : \
$(LIBCXX_SRC_FOLDER)/valarray.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/valarray.cpp \
	-o cxx_obj/valarray.o

cxx_obj/variant.o : \
$(LIBCXX_SRC_FOLDER)/variant.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/variant.cpp \
	-o cxx_obj/variant.o

cxx_obj/vector.o : \
$(LIBCXX_SRC_FOLDER)/vector.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/vector.cpp \
	-o cxx_obj/vector.o

cxx_obj/support/win32/locale_win32.o : \
$(LIBCXX_SRC_FOLDER)/support/win32/locale_win32.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/support/win32/locale_win32.cpp \
	-o cxx_obj/support/win32/locale_win32.o

cxx_obj/support/win32/support.o : \
$(LIBCXX_SRC_FOLDER)/support/win32/support.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/support/win32/support.cpp \
	-o cxx_obj/support/win32/support.o

cxx_obj/support/win32/thread_win32.o : \
$(LIBCXX_SRC_FOLDER)/support/win32/thread_win32.cpp
	g++ -c $(LIBCXX_FLAGS) $(LIBCXX_DEFINES) \
	$(LIBCXX_INC) $(LIBCXXABI_INC) \
	$(LIBCXX_SRC_FOLDER)/support/win32/thread_win32.cpp \
	-o cxx_obj/support/win32/thread_win32.o

clean:
	rd /s /q cxx_obj
	rd /s /q cxxabi_obj
