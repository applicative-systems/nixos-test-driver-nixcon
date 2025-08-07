_: prev: {
  icewm = prev.icewm.overrideAttrs (oldAttrs: {
    postInstall =
      oldAttrs.postInstall or ""
      + ''
        cp ${./nixcademy.png} $out/share/icewm/themes/default/default.png
      '';
  });
}
