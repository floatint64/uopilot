# TODO

## Миграция VCL → Lazarus/LCL

- В перспективе заменить локальный VCL-SynEdit (`synedit/`) на Lazarus-овый SynEdit
  из `components/synedit` и перевести код на `TSynEdit`/`TSynMemo` вместо точечных
  `{$IFNDEF FPC}`-правок вендорных исходников (см. `synedit/SynEditMiscClasses.pas`).
