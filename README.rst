dotfiles
========

Managed using toml-bombadil_.

First use:

.. code:: nu

   bombadil link -p $nu.os-info.name

Afterwards the ``'bombadil link'`` and ``'bombadil watch'`` functions in ``nushell/config.nu`` supply ``-p``.

Needs the following packages:

- ``carapace`` (called ``carapace-bin`` on Arch Linux)
- ``bat``, ``exa``, ``ripgrep``

On Linux also:

- ``ksshaskpass``
- ``pkgfile``

.. _toml-bombadil: https://oknozor.github.io/toml-bombadil/
