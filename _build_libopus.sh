function build_libopus {
  if [ "${WITH_LIBOPUS}" != "1" ]; then
    return
  fi

  echo "Building libopus for android ..."

  # download libopus
  libopus_version=1.1
  libopus_archive=${src_root}/opus-${libopus_version}.tar.gz
  if [ ! -f "${libopus_archive}" ]; then
    test -x "$(which curl)" || die "You must install curl!"
    curl -s http://downloads.xiph.org/releases/opus/opus-${libopus_version}.tar.gz -o ${libopus_archive} >> ${build_log} 2>&1 || \
      die "Couldn't download libopus sources!"
  fi

  # extract libopus
  if [ ! -d "${src_root}/libopus" ]; then
    cd ${src_root}
    tar zxvf ${libopus_archive} >> ${build_log} 2>&1 || die "Couldn't extract libopus sources!"
	mkdir libopus
    mv opus-${libopus_version} libopus/jni
  fi

  cd ${src_root}/libopus
  cp ${patch_root}/libopus/*.mk jni/ >> ${build_log} 2>&1 || die "Couldn't apply NDK build bits!"

  NDK_PROJECT_PATH=. ${NDK}/ndk-build ${MAKEOPTS} >> ${build_log} 2>&1 || die "Couldn't build libopus!"

  # generate pkgconfig file
  sed "s#@PREFIX@#${dist_root}#g" < ${patch_root}/libopus/opus.pc.in > ${src_root}/libopus/opus.pc || die "Couldn't generate pkgconfig file!"

  cp ${src_root}/libopus/libs/armeabi/libopus.so ${dist_lib_root}/
  # copy the headers
  mkdir -p ${dist_include_root}/opus
  cp -r ${src_root}/libopus/jni/include/* ${dist_include_root}/opus/

  cd ${top_root}
}


# vim:set ai et ts=2 sw=2 sts=2 fenc=utf-8:
