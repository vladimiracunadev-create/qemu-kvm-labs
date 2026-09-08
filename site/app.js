const labs = [
  ["01","Host y KVM","CPU, permisos y capacidades"],
  ["02","Discos","qcow2, raw y backing files"],
  ["03","Boot media","ISO, cloud image y firmware"],
  ["04","Cloud-init + SSH","Provisioning reproducible"],
  ["05","Redes","NAT, bridge y TAP"],
  ["06","Snapshots","Restore y cloning"],
  ["07","Virtio","Disco, NIC y canales"],
  ["08","Recursos","CPU pinning y memoria"],
  ["09","Guest agent","Control coordinado"],
  ["10","UEFI + consola","XML, SPICE y VNC"],
  ["11","Fallos","Red, memoria y disco"],
  ["12","Migración","Dos hosts + vm-manager"]
];
document.querySelector("#labs").innerHTML = labs.map(([id,title,detail]) =>
  "<article class='card'><b>" + id + "</b><h3>" + title + "</h3><p>" + detail + "</p></article>"
).join("");
