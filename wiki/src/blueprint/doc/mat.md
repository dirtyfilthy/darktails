[[!tag archived]]

[[!meta title="MAT"]]

What is MAT?
============

MAT (Metadata Anonymisation Toolkit) is a toolkit that anonymizes and removes
metadata from your files. It does this utilizing a library, a GUI application
and, if you prefer, a CLI application.

How does it work?
=================

Simply put, MAT removes all metadata from files leaving them empty.
Unfortunately, watermarks and steganographic tags won’t be removed but unlike
metadata being added by default by many utilities, watermarks are not usually
inadvertently added and the original author will likely be aware of their
existence. Basically, MAT will protect you from accidental metadata leakage,
but not customized metadata specifically included to track down you, the
author.

Why do we care?
===============

Because just about every file being uploaded to the internet contains metadata.
From Office documents to .flac audio files and beyond, they all have metadata
embedded, and that metadata tells the world where, when, and most crucially,
who uploaded it. This defeats the purpose of Tails and our ‘privacy for anyone,
anywhere’ mantra.

So, to ensure you stay anonymous, Tails comes with MAT included.

Currently supported files include:

  - Portable Network Graphics (.png)
  - JPEG (.jpg, .jpeg, etc)
  - Open Documents (.odt, .odx, .ods, etc)
  - Office OpenXml (.docx, .pptx, .xlsx, etc)
  - Tape ARchives (.tar, .tar.bz2, etc)
  - MPEG AUdio (.mp3, .mp2, .mp1, etc)
  - Ogg Vorbis (.ogg, etc)
  - Free Lossless Audio Codec (.flac)
  - Torrent (.torrent)

MAT can be accessed via: Applications > System Tools in the Tails GUI.
