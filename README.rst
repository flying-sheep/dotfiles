dotfiles
========

Managed using toml-bombadil_.

First use:

.. code:: nu

    bombadil link -p $nu.os-info.name

Afterwards the ``'bombadil link'`` function in ``nushell/config.nu`` supplies ``-p``.

Needs the following packages on Linux:

.. code:: bash

    pacman -Qq >/dev/null \
        prezto \
        thefuck undistract-me-git pkgfile \
        bat exa \
        ksshaskpass xdotool


.. _toml-bombadil: https://oknozor.github.io/toml-bombadil/
