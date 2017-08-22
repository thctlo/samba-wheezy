#!/bin/bash

export cmocka="1.0.1"

echo "Build source tarballs"
echo "====================="

for i in *.files
do
	name=`echo $i | sed -e 's/\(.*\)_.*/\1/'`
	version=`echo $i | sed -e 's/.*_\(.*\)\.orig.*/\1/'`
	compression=`echo $i | sed -e 's/.*\.orig\.tar\.\(.*\)\.files/\1/'`

	if [ -d "${name}-${version}" ]; then
  	  cd ${name}-${version}
	  echo ${name}-${version}
	  case $compression in 
	    gz)
  	      tar -czf ../${name}_${version}.orig.tar.$compression --files-from ../$i
  	    ;;
  	    xz)
  	      tar -cJf ../${name}_${version}.orig.tar.$compression --files-from ../$i
  	    ;;
  	  esac
  	  cd ..
  	fi
done

  