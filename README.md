# luks-uuid-root

## Description
> [!IMPORTANT]
> I have done almost nothing, most of the code is taken from [the official make-initrd github repository](https://github.com/osboot/make-initrd) and belongs to [osboot](https://github.com/osboot/) and other make-initrd's сontributors.

This feature is a slight change to the original luks feature in [make-initrd](https://github.com/osboot/make-initrd). It differs from the standard feature in that it forces the UUID to be used to perceive the path to the root partition (e.g. ```/dev/disk/by-uuid/<UUID_of_encrypted_root>```), instead of the usual ```/dev/sdxN```.

## Reason
The standard make-initrd's luks feature automatically detects the encrypted root as the path to the partition on which it is located (such as ```/dev/sdxN```) and only perceives this path. Using a path with a UUID in ```luksdev```/```luks-device``` results in an unlocking error due to the lack of a record of the location of the key for the root partition. 
If you use automatic unlocking of the root partition using a pre-recorded key, then with the standard method of perceiving the path to the root partition, connecting a new block device can lead to the system simply stopping turning on. 

For example, by default the user's root partition is defined as ```/dev/sda1```, then if the user connects some other block device before starting the system, the path of the root partition may change to, for example, ```/dev/sdb1```. In this case, the system simply will not start, because the entry for ```/dev/sdb1``` most likely does not exist at the time the path is changed.
If you use this feature, this can be avoided, since it uses the UUID for path to the root (e.g. ```/dev/disk/by-uuid/<UUID_of_encrypted_root>```).
The most interesting thing is that the original feature itself seems to support the use of UUIDs for encrypted devices, but the problem lies precisely in the script for determining the root partition.

## Installing
> [!CAUTION]
> **Use it at your own risk! The author is not responsible for any damage caused!**

> [!WARNING]
> It is not compitable with original make-initrd's luks feature. After install you need to change your kernel boot options or ```/etc/luks.keys```

1. Clone repo:
   ```
   git clone https://github.com/midnight-carrier/luks-uuid-root.git
   ```

2. Enter to directory:
   ```
   cd luks-uuid-root
   ```

3. Make install script ```install.sh``` executable:
   ```
   chmod +x ./install.sh
   ```

4. Run script as root:
   ```
   sudo bash -c "./install.sh"
   ```
   You can specify the path to you make-initrd instance, by writing path as first argue of script. By default path = ```/usr/share/make-initrd```:
   ```
   sudo bash -c "./install [path]"
   ```

5. Recompile ramdisk:
   ```
   sudo make-initrd
   ```

## Usage
> [!NOTE]
> Starting from version **v1.1.0**, you can use ```UUID=``` prefix for specifying path to root partition.
> ```/etc/luks.keys``` and boot kernel options for **v1.0.0** is fully compatible with **v1.1.0**.

> [!WARNING]
> This feature can perceive the path to the root partition, only using the UUID (e.g. ```/dev/disk/by-uuid/<UUID_of_encrypted_root>``` or ```UUID=<UUID_of_encrypted_root>```).

> [!WARNING]
> Be very careful when composing the ```/etc/luks.keys``` file. This feature, like its parent, is very sensitive to spaces and tabs.

The use of this feature is almost compatible with the original documentation, however, when it comes to the root partition, this is where the changes lie. Below is a small part of the information from the original documentation, which has been modified for use with this feature. The untouched part of the original documentation should be ideal for this feature as well. [See README.md of original make-initrd's luks feature](https://github.com/osboot/make-initrd/blob/master/features/luks/README.md) for more info.

### Boot parameters
 - `luks-key=`
  - `<keypath>[:<keydev>][:<luksdev>]` key for luks device on removable device
    - `keypath` is a path to key file to look for from root of `keydev`.
    - `keydev` is a device on which key file resides.
    - if `luksdev` is given, the specified key will only be applied for that LUKS device. When it is root partition, you should specify the path using the UUID: ```/dev/disk/by-uuid/<UUID_of_encrypted_root>``` or ```UUID=<UUID_of_encrypted_root>```. Possible values are the same as for keydev. Unless you have several LUKS devices, you don’t have to specify this parameter.



### /etc/luks.keys

You can put the ```/etc/luks.keys``` file in initramfs and then you do not need to specify boot options. [See official make-initrd's documentation.](https://github.com/osboot/make-initrd/blob/master/Documentation/Configuration.md#image-generation-settings) The file describes which keys for which LUKS partitions to use and where to find them. 
The file contains entries separated by a single tab character. Each entry describes one key file.
```
key-path[<TAB>key-device[<TAB>luks-device]]
```
```key-path``` - this is the path from the ```key-device``` to the file that contains the key needed to unlock ```luks-device```.
When ```luks-device``` is root partition, you need to specify path, using UUID of ```luks-device```: ```/dev/disk/by-uuid/<UUID_of_encrypted_root>``` or ```UUID=<UUID_of_encrypted_root>```.

### Examples
Auto-unlock root using boot parametrs (keydev and root it's different devices):
```
luks-key=keys/luks.key:/dev/disk/by-uuid/5290c5a4-be85-439c-ad66-f2c29a63d51d:/dev/disk/by-uuid/2ef38590-f418-44d0-94fb-8387fe7463c4
```

Auto-unlock root using /etc/luks.keys (keydev and root it's different devices):
```
keys/luks.key  UUID=507a32b1-3082-4fe8-a69a-0c7a1c71808e  /dev/disk/by-uuid/d6fdca5e-5a04-4fa3-b8ae-236b0d2bc2ec
```

Auto-unlock root using /etc/luks.keys (keydev and root it's different devices):
```
keys/luks.key  UUID=507a32b1-3082-4fe8-a69a-0c7a1c71808e   UUID=d6fdca5e-5a04-4fa3-b8ae-236b0d2bc2ec
```
