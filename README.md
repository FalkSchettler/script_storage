# Helper Scripts for the Daily Business

## gdiff3(file, [branch to compare])

Performs a three-way diff in git without changing the working copy and works for text files and enterprise architecture models (with and without LFS).

Default without additional branch, compare again origin/master

```bash
gdiff3 Model.EAPX
```

```bash
gdiff3 Model.EAPX maint/whatever
gdiff3 Model.EAPX master
```
