cd ../../FSILBM3D
make clean
make
cd ../FSILBM3D_example/examples
sleep 1
for frqcase in */; do
  [ -d "${frqcase}" ] || continue
  frqcase="${frqcase%/}"

  cd "${frqcase}"
  if [ ! -f runlog ]; then
    cd ..
    continue
  fi

  echo -n "testing ${frqcase} ... "
  start=$(date +%s)

  rm -rf test
  mkdir test
  cp ./*.dat test/ 2>/dev/null || true
  cp ./*.msh test/ 2>/dev/null || true
  cp ./*.sh test/ 2>/dev/null || true

  cd test
  for folder in DatBodySpan DatInfo DatBody DatFlow DatContinue
  do
    if [[ -d $folder ]]; then
      rm -r $folder
      mkdir $folder
    else
      mkdir $folder
    fi
  done

  ../../../../FSILBM3D/FSILBM3D &> newrunlog
  awk '{if($1=="FIELDSTAT") print $2, $3, $4}' newrunlog > newfield
  awk '{if($1=="FIELDSTAT") print $2, $3, $4}' ../runlog > oldfield
  sed -i 's/\r//' newfield
  sed -i 's/\r//' oldfield
  end=$(date +%s)
  echo -n "Time used $(($end-$start)) seconds. "
  if awk '
    NR==FNR {
      n = n + 1
      old_name[n] = $1 " " $2
      old_val[n] = substr($3, 1, 8)
      next
    }
    {
      m = m + 1
      new_name[m] = $1 " " $2
      new_val[m] = substr($3, 1, 8)
    }
    END {
      if (n != m) exit 1
      for (i = 1; i <= n; i++) {
        if (old_name[i] != new_name[i]) exit 1
        if (old_val[i] != new_val[i]) exit 1
      }
    }
  ' oldfield newfield; then
      echo "Passed."
  else
      echo "Failed."
      echo "oldfield"
      cat oldfield
      echo "newfield"
      cat newfield
  fi

  cd ..
  rm -rf test
  cd ..
done
