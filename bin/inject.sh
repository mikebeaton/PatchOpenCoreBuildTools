#!/bin/sh

echo $ cd ~/injected
pushd ~/injected 1>/dev/null || exit 1

if [ "$1" != "-n" ] ; then
  echo cp ~/OpenSource/OpenCorePkg/UDK/Build/OpenCorePkg/RELEASE_XCODE5/FV/Ffs/3FBA58B1-F8C0-41BC-ACD8-253043A3A17FEnableGop/3FBA58B1-F8C0-41BC-ACD8-253043A3A17F.ffs EnableGop.ffs
  cp ~/OpenSource/OpenCorePkg/UDK/Build/OpenCorePkg/RELEASE_XCODE5/FV/Ffs/3FBA58B1-F8C0-41BC-ACD8-253043A3A17FEnableGop/3FBA58B1-F8C0-41BC-ACD8-253043A3A17F.ffs EnableGop.ffs || exit 1

  echo cp ~/OpenSource/OpenCorePkg/UDK/Build/OpenCorePkg/RELEASE_XCODE5/FV/Ffs/3FBA58B1-F8C0-41BC-ACD8-253043A3A17FEnableGopDirect/3FBA58B1-F8C0-41BC-ACD8-253043A3A17F.ffs EnableGopDirect.ffs
  cp ~/OpenSource/OpenCorePkg/UDK/Build/OpenCorePkg/RELEASE_XCODE5/FV/Ffs/3FBA58B1-F8C0-41BC-ACD8-253043A3A17FEnableGopDirect/3FBA58B1-F8C0-41BC-ACD8-253043A3A17F.ffs EnableGopDirect.ffs || exit 1
fi

echo $ ~/Tools/DXEInject CK9200GC8PZ\ -\ reconstructed.144.base_21.VSS.rom injected.rom EnableGop.ffs
~/Tools/DXEInject CK9200GC8PZ\ -\ reconstructed.144.base_21.VSS.rom injected.rom EnableGop.ffs || exit 1

echo $ ~/Tools/DXEInject CK9200GC8PZ\ -\ reconstructed.144.base_21.VSS.rom injected_direct.rom EnableGopDirect.ffs
~/Tools/DXEInject CK9200GC8PZ\ -\ reconstructed.144.base_21.VSS.rom injected_direct.rom EnableGopDirect.ffs || exit 1

echo $ cp injected.rom ~/Public
cp injected.rom ~/Public || exit 1

echo $ cp injected_direct.rom ~/Public
cp injected_direct.rom ~/Public || exit 1

popd 1>/dev/null || exit 1

ls -alrt ~/Public/injected*.rom
