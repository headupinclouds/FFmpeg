cmake_minimum_required(VERSION 3.2)

include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.23.155.tar.gz"
    SHA1 "6421d63cc4fd78b8622e863c6b1dcabce98e1216"
)

project(ffmpeg VERSION 4.1)

set(ffmpeg_native_gen_dir "${CMAKE_CURRENT_BINARY_DIR}/ffmpeg_native_gen")
file(MAKE_DIRECTORY "${ffmpeg_native_gen_dir}")

set(
    configure_script
    ${CMAKE_CURRENT_LIST_DIR}/configure
)

if(BUILD_SHARED_LIBS)
  list(
      APPEND
      configure_script
      --disable-static
      --enable-shared
  )
else()
  list(
      APPEND
      configure_script
      --disable-shared
      --enable-static
  )
endif()


list(
    APPEND
    configure_script

    # Licensing options:
    --enable-gpl # need for libx264

    # Standard options:
    --fatal-warnings

    # Program options:
    --disable-programs  # don't disable for ffmpeg tool

    # Documentation options
    --disable-doc
    --disable-htmlpages
    --disable-manpages
    --disable-podpages
    --disable-txtpages

    # Component options:
    --disable-avfilter # don't disable for ffmpeg tool
    --disable-avdevice
    --disable-postproc
    --disable-avresample
    --disable-network

    # Individual component options:
    --disable-everything
    --enable-decoder=h264
    --enable-demuxer=mov
    --enable-parser=h264

    --enable-muxer=image2 # https://superuser.com/a/915337
    --enable-demuxer=image2
    --enable-protocol=file
    --enable-encoder=bmp

    --enable-filter=scale,overlay  # 'scale' filter not present

    # External library support:
    --disable-autodetect
    --enable-libx264

    # Toolchain options:
    --enable-cross-compile
    --cc=${CMAKE_C_COMPILER}
    --cxx=${CMAKE_CXX_COMPILER}

    # Advanced options (experts only):

    # Optimization options (experts only):
    --disable-asm

    # Developer options (useful when working on FFmpeg itself):
    --enable-debug
    --disable-optimizations
  )

# Add the x264 package and set PKG_CONFIG_PATH hint to X264_ROOT (for ffmpeg)
hunter_add_package(x264)
find_package(x264 CONFIG REQUIRED)
set(ENV{PKG_CONFIG_PATH} ${X24_ROOT}/lib/pkgconfig)

# Must be able to find libx264
execute_process(
    COMMAND
    ${configure_script}
    RESULT_VARIABLE
    result
    WORKING_DIRECTORY
    ${ffmpeg_native_gen_dir}
)

if(NOT result EQUAL "0")
  message(FATAL_ERROR "Configure failed: ${result}")
endif()

# Fixup CFLAGS and CXXFLAGS from autoconf output
option(FFMPEG_AUTOCONF_FLAGS "Grep flags from autoconf" OFF)

if(FFMPEG_AUTOCONF_FLAGS)
  file(READ "${ffmpeg_native_gen_dir}/ffbuild/config.mak" file_content)
  foreach(flag CFLAGS CXXFLAGS CPPFLAGS)
    string(REGEX MATCH "[\r|\n]${flag}=([^\r\n]+)[\r\n]" _ "${file_content}")
    if(NOT ${CMAKE_MATCH_COUNT} EQUAL 1)
      message(FATAL_ERROR "Could not find generated ${flag}")
    endif()
    set(${flag} "${CMAKE_MATCH_1}")
    string(REPLACE "$(SRC_PATH)" "${CMAKE_CURRENT_LIST_DIR}" ${flag} "${${flag}}")
  endforeach()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXXFLGAS} ${CPPFLAGS}")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CFLAGS} ${CPPFLAGS}")
endif()

# BUILD.gn
# config("external_config")

set(
  ffmpeg_codec_files
  libavcodec/ac3_parser.c
  libavcodec/ac3tab.c
  libavcodec/adts_parser.c
  libavcodec/allcodecs.c
  libavcodec/avdct.c
  libavcodec/avpacket.c
  libavcodec/avpicture.c
  libavcodec/bitstream.c
  libavcodec/bitstream_filter.c
  libavcodec/bitstream_filters.c
  libavcodec/bmpenc.c
  libavcodec/bsf.c
  libavcodec/cabac.c
  libavcodec/codec_desc.c
  libavcodec/d3d11va.c
  libavcodec/decode.c
  libavcodec/dirac.c
  libavcodec/dv_profile.c
  libavcodec/encode.c
  libavcodec/error_resilience.c
  libavcodec/faandct.c
  libavcodec/faanidct.c
  libavcodec/fdctdsp.c
  libavcodec/frame_thread_encoder.c
  libavcodec/golomb.c
  libavcodec/h2645_parse.c
  libavcodec/h264_cabac.c
  libavcodec/h264_cavlc.c
  libavcodec/h264_direct.c
  libavcodec/h264_loopfilter.c
  libavcodec/h264_mb.c
  libavcodec/h264_parse.c
  libavcodec/h264_parser.c
  libavcodec/h264_picture.c
  libavcodec/h264_ps.c
  libavcodec/h264_refs.c
  libavcodec/h264_sei.c
  libavcodec/h264_slice.c
  libavcodec/h264chroma.c
  libavcodec/h264data.c
  libavcodec/h264dec.c
  libavcodec/h264dsp.c
  libavcodec/h264idct.c
  libavcodec/h264pred.c
  libavcodec/h264qpel.c
  libavcodec/idctdsp.c
  libavcodec/imgconvert.c
  libavcodec/jfdctfst.c
  libavcodec/jfdctint.c
  libavcodec/jni.c
  libavcodec/jrevdct.c
  libavcodec/mathtables.c
  libavcodec/me_cmp.c
  libavcodec/mediacodec.c
  libavcodec/mjpegenc_huffman.c
  libavcodec/mpeg12framerate.c
  libavcodec/mpeg4audio.c
  libavcodec/mpegaudiodata.c
  libavcodec/null_bsf.c
  libavcodec/options.c
  libavcodec/parser.c
  libavcodec/parsers.c
  libavcodec/pixblockdsp.c
  libavcodec/profiles.c
  libavcodec/pthread.c
  libavcodec/pthread_frame.c
  libavcodec/pthread_slice.c
  libavcodec/qsv_api.c
  libavcodec/raw.c
  libavcodec/simple_idct.c
  libavcodec/startcode.c
  libavcodec/utils.c
  libavcodec/v4l2_buffers.c
  libavcodec/v4l2_context.c
  libavcodec/v4l2_fmt.c
  libavcodec/v4l2_m2m.c
  libavcodec/videodsp.c
  libavcodec/vorbis_parser.c
  libavcodec/xiph.c
)

add_library(avcodec ${ffmpeg_codec_files})

# Minimal config add x264 depenedency:
target_link_libraries(avcodec PUBLIC PkgConfig::x264)

set(
  ffmpeg_format_files
  libavformat/allformats.c
  libavformat/avio.c
  libavformat/aviobuf.c
  libavformat/cutils.c
  libavformat/dump.c
  libavformat/file.c
  libavformat/format.c
  libavformat/id3v1.c
  libavformat/id3v2.c
  libavformat/img2.c
  libavformat/img2dec.c
  libavformat/img2enc.c
  libavformat/isom.c
  libavformat/metadata.c
  libavformat/mov.c
  libavformat/mov_chan.c
  libavformat/mov_esds.c
  libavformat/mux.c
  libavformat/options.c
  libavformat/os_support.c
  libavformat/protocols.c
  libavformat/qtpalette.c
  libavformat/replaygain.c
  libavformat/riff.c
  libavformat/riffdec.c
  libavformat/sdp.c
  libavformat/url.c
  libavformat/utils.c
)

add_library(avformat ${ffmpeg_format_files})
target_link_libraries(avformat PUBLIC avcodec)

set(
  ffmpeg_util_files
  libavutil/adler32.c
  libavutil/aes.c
  libavutil/aes_ctr.c
  libavutil/audio_fifo.c
  libavutil/avstring.c
  libavutil/base64.c
  libavutil/blowfish.c
  libavutil/bprint.c
  libavutil/buffer.c
  libavutil/camellia.c
  libavutil/cast5.c
  libavutil/channel_layout.c
  libavutil/color_utils.c
  libavutil/cpu.c
  libavutil/crc.c
  libavutil/des.c
  libavutil/dict.c
  libavutil/display.c
  libavutil/downmix_info.c
  libavutil/encryption_info.c
  libavutil/error.c
  libavutil/eval.c
  libavutil/fifo.c
  libavutil/file.c
  libavutil/file_open.c
  libavutil/fixed_dsp.c
  libavutil/float_dsp.c
  libavutil/frame.c
  libavutil/hash.c
  libavutil/hmac.c
  libavutil/hwcontext.c
  libavutil/imgutils.c
  libavutil/integer.c
  libavutil/intmath.c
  libavutil/lfg.c
  libavutil/lls.c
  libavutil/log.c
  libavutil/log2_tab.c
  libavutil/mastering_display_metadata.c
  libavutil/mathematics.c
  libavutil/md5.c
  libavutil/mem.c
  libavutil/murmur3.c
  libavutil/opt.c
  libavutil/parseutils.c
  libavutil/pixdesc.c
  libavutil/pixelutils.c
  libavutil/random_seed.c
  libavutil/rational.c
  libavutil/rc4.c
  libavutil/reverse.c
  libavutil/ripemd.c
  libavutil/samplefmt.c
  libavutil/sha.c
  libavutil/sha512.c
  libavutil/slicethread.c
  libavutil/spherical.c
  libavutil/stereo3d.c
  libavutil/tea.c
  libavutil/threadmessage.c
  libavutil/time.c
  libavutil/timecode.c
  libavutil/tree.c
  libavutil/twofish.c
  libavutil/utils.c
  libavutil/xga_font_data.c
  libavutil/xtea.c
)

add_library(avutil ${ffmpeg_util_files})

set(
  ffmpeg_swresample_files
  libswresample/audioconvert.c
  libswresample/dither.c
  libswresample/options.c
  libswresample/rematrix.c
  libswresample/resample.c
  libswresample/resample_dsp.c
  libswresample/swresample.c
  libswresample/swresample_frame.c
)

add_library(swresample ${ffmpeg_swresample_files})

set(
  ffmpeg_swscale_files
  libswscale/alphablend.c
  libswscale/gamma.c
  libswscale/hscale.c
  libswscale/hscale_fast_bilinear.c
  libswscale/input.c
  libswscale/options.c
  libswscale/output.c
  libswscale/rgb2rgb.c
  libswscale/slice.c
  libswscale/swscale.c
  libswscale/swscale_unscaled.c
  libswscale/utils.c
  libswscale/vscale.c
  libswscale/yuv2rgb.c
)

add_library(swscale ${ffmpeg_swscale_files})

# Link order is important, see configure scrip
# avio_reading_deps="avformat avcodec avutil"
# etc
set(
    all_targets
    avformat
    avcodec
    avutil
    swscale
    swresample
)

foreach(x ${all_targets})

  target_compile_definitions(
      ${x}
      PRIVATE
      HAS_SWSCALE

      # BUILD.gn
      # config("internal_config")
      HAVE_AV_CONFIG_H
  )

  target_include_directories(
      ${x}
      PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/forced>
      $<BUILD_INTERFACE:${ffmpeg_native_gen_dir}>
  )
endforeach()

### Installation (https://github.com/forexample/package-example) {

# Introduce variables:
# * CMAKE_INSTALL_LIBDIR
# * CMAKE_INSTALL_BINDIR
# * CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

set(config_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(NAMESPACE "${PROJECT_NAME}::")

include(CMakePackageConfigHelpers)

# Use:
# * PROJECT_VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Use:
# * TARGETS_EXPORT_NAME
# * PROJECT_NAME
configure_package_config_file(
    "cmake/template/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)

install(
    EXPORT "${TARGETS_EXPORT_NAME}"
    NAMESPACE "${NAMESPACE}"
    DESTINATION "${config_install_dir}"
)

### }

install(
    TARGETS ${all_targets}
    EXPORT "${TARGETS_EXPORT_NAME}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

install(
    DIRECTORY
    libavcodec
    libavformat
    libavutil
    libswresample
    libswscale
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING
    PATTERN "*.h"
)

install(
    FILES
    ${ffmpeg_native_gen_dir}/libavutil/avconfig.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libavutil
)

install(
    FILES ${ffmpeg_native_gen_dir}/config.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libavutil
)

install(
    FILES ${ffmpeg_native_gen_dir}/config.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libavformat
)
