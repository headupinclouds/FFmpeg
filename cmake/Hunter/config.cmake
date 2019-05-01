# set(x264_url "file:///home/dhirvonen/devel/hunter-packages/x264.tar.gz")
# set(x264_sha1 "209143be93a90ced7eb5106a7398bcfcd7001c9f")
# set(x264_args X264_AUTOCONF_FLAGS=ON DUMMY=3)
# hunter_config(X264 URL ${x264_url} SHA1 ${x264_sha1} CMAKE_ARGS ${x264_args})

set(x264_url "ftp://ftp.videolan.org/pub/x264/snapshots/x264-snapshot-20190430-2245.tar.bz2")
set(x264_sha1 "704b27fc5fb816a12cf99d4e01484ee0a9466ec4")
hunter_config(x264 URL ${x264_url} SHA1 ${x264_sha1})

