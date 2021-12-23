#!/bin/bash

# Делаем snapshot
yc compute instance list | while read line ; do
  vm_id=$(echo $line | awk '{print $2}')

  #Фильтруем пустые строки и разметку
  if [[ ${#vm_id} -lt 10 ]]; then
    continue
  fi

  vm_name=$(echo $line | awk '{print $4}')
  disk_id=$(yc compute disk list | grep $vm_id | awk '{print $2}')

  yc compute snapshot create "backup-${vm_name}-snap-$(date +%Y-%m-%d-%H-%M)" --disk-id $disk_id
done


# Удаляем старые snapshot
yc compute snapshot list | while read line; do
  snap_name=$(echo $line | awk '{print $4}')

  #Фильтруем пустые строки и разметку
  if [[ ${#snap_name} -lt 10 ]]; then
    continue
  fi

  snap_id=$(echo $line | awk '{print $2}')
  snap_day=$(echo $snap_name | awk -F- '{print $6}')
  today=$(date +%d)

  # Проверяем не перешел ли месяц в следующий, чтобы корректно вычислить 7 дней разницы. Условно принимаем месяц за 31 день
  if [[ today -lt snap_day ]]; then
    let today=$today+31
  fi

  let dif=$today-$snap_day

  if [[ $dif -gt 7 ]]; then
    yc compute snapshot delete --id $snap_id
  fi
done
