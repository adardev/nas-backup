<?php

/**
 * Backend para filesystem fuse.mergerfs en OpenMediaVault.
 *
 * OMV no incluye soporte nativo para fuse.mergerfs. Este archivo
 * permite que OMV reconozca y gestione pools mergerfs.
 *
 * Copiar a: /usr/share/php/openmediavault/system/filesystem/backend/
 */

namespace OMV\System\Filesystem\Backend;

class FuseMergerfs extends BackendAbstract
{
    public function __construct()
    {
        $this->type = "fuse.mergerfs";
    }
}
