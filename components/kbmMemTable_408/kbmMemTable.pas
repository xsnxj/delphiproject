unit kbmMemTable;

interface

{$include kbmMemTable.inc}

// kbmMemTable v. 4.08
// =========================================================================
// An inmemory temporary table.
//
// Copyright 1999-2004 Kim Bo Madsen/Components4Developers
// All rights reserved.
//
// LICENSE AGREEMENT
// PLEASE NOTE THAT THE LICENSE AGREEMENT HAS CHANGED!!! 1. Aug. 2003
//
// You are allowed to use this component in any application for free.
// You are NOT allowed to claim that you have created this component or to
// copy its code into your own component and claim that it was your idea/code.
//
// -----------------------------------------------------------------------------------
// IM OFFERING THIS FOR FREE FOR YOUR CONVINIENCE, BUT
// YOU ARE REQUIRED TO SEND AN E-MAIL ABOUT WHAT PROJECT THIS COMPONENT (OR DERIVED VERSIONS)
// IS USED FOR !
// -----------------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------------
// PLEASE NOTE THE FOLLOWING CHANGES TO THE LICENSE AGREEMENT:
// 1. Aug. 2003
// Parts of the package which constitute kbmMemTable Pro is not open source nor freware.
// These parts may not be disclosed to any 3rdparty without prior written agreement with
// Components4Developers.
// Discussion in public fora about the algorithms used in those parts is not permitted.
// Each unit which is under that part of the license agreement have it specifically
// written in the top of the unit file as part of its own specific license agreement
//
// 25. Jul. 2003
// You are allowed to use this component in any application for free.
// You are not allowed to use the knowledge gained from this component or any code
// from it for creating applications or developer tools directly competing with any
// C4D tool unless specifically approved in writing by C4D.
// If you choose to make developer tools containing this component you are required to
// acknowledge that visually in the application/tool/library f.ex. in the About box,
// or in the beginning of the central documentation for the application/tool/library.
// The acknowledgement must contain a link or reference to www.components4developers.com
// You dont need to state my name in your end user application, unless its covered under
// the previous phrase, although it would be appreciated if you do.
// -----------------------------------------------------------------------------------
//
// If you find bugs or alter the component (f.ex. see suggested enhancements
// further down), please DONT just send the corrected/new code out on the internet,
// but instead send it to me, so I can put it into the official version. You will
// be acredited if you do so.
//
//
// DISCLAIMER
// By using this component or parts theirof you are accepting the full
// responsibility of the use. You are understanding that the author cant be
// made responsible in any way for any problems occuring using this component.
// You also recognize the author as the creator of this component and agrees
// not to claim otherwize!
//
// Please forward corrected versions (source code ONLY!), comments,
// and emails saying you are using it for this or that project to:
//            kbm@components4developers.com
//
// Latest version can be found at:
//            http://www.components4developers.com
//
// Suggestions for future enhancements:
//
//      - IDE designer for adding static data to the memtable.
//      - Optimized sorting. Combosort, many way mergesort or the like for large datasets.
//      - Swap functionality for storing parts of an active table on disk for
//        preserving memory.
//
// History:
//
//1.00:	The first release. Was created due to a need for a component like this.
//                                                                    (15. Jan. 99)
//1.01:	The first update. Release 1.00 contained some bugs related to the ordering
//	    of records inserted and to bookmarks. Problems fixed.         (21. Jan. 99)

//1.02:	Fixed handling of NULL values. Added SaveToStream, SaveToFile,
//	    LoadFromStream and LoadFromFile. SaveToStream and SaveToFile is controlled
//	    by a flag telling if to save data, contents of calculated fields,
//	    contents of lookupfields and contents of non visible fields.
//	    Added an example application with Delphi 3 source code.       (26. Jan. 99)
//
//1.03: Claude Rieth from Computer Team sarl (clrieth@team.lu) came up with an
//      implementation of CommaText and made a validation check in _InternalInsert.
//      Because I allready have implemented the saveto.... functions, I decided
//      to implement Claude's idea using my own saveto.... functions. (27. Jan. 99)
//      I have decided to rename the component, because Claude let me know that
//      the RX library have a component with the same name as this.
//      Thus in the future the component will be named TkbmMemTable.
//      SaveToStream and LoadFromStream now set up date and decimal separator
//      temporary to make sure that the data saved can be loaded on another
//      installation with different date and decimal separator setups.
//      Added EmptyTable method to clear the contents of the memory table.
//
//1.04: Wagner ADP (wagner@cads-informatica.com.br) found a bug in the _internalinsert
//      procedure which he came up with a fix for.                     (4. Feb. 99)
//      Added support for the TDataset protected function findrecord.
//      Added support for CreateTable, DeleteTable.
//
//1.05: Charlie McKeegan from Task Software Limited (charlie@task.co.uk) found
//      a minor bug (and came up with a fix) in SetRecNo which mostly is
//      noticeable in a grid where the grid wont refresh when the record slider
//      is moved to the end of the recordset.                          (5. Feb. 99)
//      Changed SaveToStream to use the displayname of the field as the header
//      instead of the fieldname.
//
//1.06: Introduced a persistence switch and a reference to a file. If the
//      persistence switch is set, the file will be read aut. on table open,
//      and the contents of the table will be saved in the table on table close.
//
//1.07: Changed calculation of fieldofsets in InternalOpen to follow the fielddefs
//      instead of fields. It has importance when rearranging fields.
//      Because of this change the calculation of fieldoffsets into the buffer
//      has been changed too. These corrections was found to be needed to
//      support the new components tkbmPooledQuery and tkbmPooledStoredProc
//      (found in the package tkbmPooledConn)
//      which in turn handles pooled connections to a database. Very usefull
//      in f.ex a WWW application as they also makes the BDE function threadsafe,
//      and limits the concurrent connections to a database.
//
//1.08: Changed buffer algorithm in GetLine since the old one was faulty.
//      Problem was pointed out by: Markus Roessler@gmx.de
//
//1.09: Added LoadFromDataset, SaveToDataset, CreateTableAs,
//      BCD and BLOB support by me.
//      James Baile (James@orchiddata.demon.co.uk) pointed out a bug in GetRecNo
//      which could lead to an endless loop in cases with filtering. He also
//      provided code for sorting, which I have been rearranging a bit and
//      implemented.
//      Travis Diamond (tdiamond@airmail.net) pointed out a bug in GetWord where
//      null fields would be skipped.
//      Claudio Driussi (c.driussi@popmail.iol.it) send me version including
//      a sort routine, and Ive used some of he's ideas to implement a sorting
//      mechanism. Further he's code contained MoveRecords and MoveCurRec which
//      I decided to include in a modified form for Drag and Drop record
//      rearrangements.
//
//1.10: Support for Locate.                                             (17. May. 99)
//      Claudio Driussi (c.driussi@popmail.iol.it) came up with a fix for
//      GetRecNo. MoveRecord is now public.
//      Andrius Adamonis (andrius@prototechnika.lt) came up with fix for
//      call to validation routines in SetFieldData and support for
//      OldValue and NewValue in GetActiveRecordBuffer.
//
//1.11: Pascalis Bochoridis from SATO S.A Greece (pbohor@sato.gr)
//      Corrected bookmark behavior (substituted RecordNo from TRecInfo with unused Bookmark)
//      Corrected GetRecNo & SetRecNo  (Scrollbars now work ok at First and Last record)
//      Added LocateRecord, Locate, Lookup (I decided to use his Locate instead of my own).
//
//1.12: Added CloseBlob. Corrected destructor.                          (26. May. 99)
//      Corrected GetFieldData and SetFieldData. Could result in overwritten
//      memory elsewhere because of use of DataSize instead of Size.
//      Pascalis Bochoridis from SATO S.A Greece (phohor@sato.gr) send me a corrected
//      LocateRecord which solves problems regarding multiple keyfields.
//      Thomas Bogenrieder (tbogenrieder@wuerzburg.netsurf.de) have suggested a faster
//      LoadFromStream version which is much faster, but loads the full stream contents into
//      memory before processing. I fixed a few bugs in it, rearranged it and decided
//      to leave it up to you what you want to use.
//      I suggest that if you need speed for smaller streams, use his method, else use mine.
//      You c an activate his method by uncommenting the define statement FAST_LOADFROMSTREAM
//      a few lines down.
//
//1.13  Corrected SetRecNo and MoveRecord.                               (31. May. 99)
//      By Pascalis Bochoridis from SATO S.A Greece (phohor@sato.gr)
//
//1.14  Respecting DefaultFields differently.                            (3. Jun. 99)
//      LoadFromDataset now includes a CopyStructure flag.
//      Supporting Master/Detail relations.
//      Now the Sort uses a new property for determining the fields to sort on,
//      which means its possible to sort on other fields than is used for
//      master/detail. Added SortOn(FieldNames:string) which is used for quick
//      addhoc sorting by just supplying the fieldnames as parameters to the
//      SortOn command.
//      Fixed memory leak in LoadFromDataset (forgot to free bookmark).
//      Added CopyFieldProperties parameter to LoadFromDataset and CreateTableAs which
//      if set to TRUE will copy f.ex. DisplayName, DisplayFormat, EditMask etc. from
//      the source.
//      Corrected OnValidate in SetFieldData. Was placed to late to have any impact.
//      Now checking for read only fields in SetFieldData.
//
//1.15  Totally rearranged LocateRecord to handle binary search when     (23. Jun. 99)
//      the data searched is sorted.
//      I was inspired by Paulo Conzon (paolo.conzon@smc.it) who send me a version with the Locate method
//      hacked for binary search. New methods PopulateRecord and PopulateField is used to create
//      a key record to search for.
//      Changed Sort and SortOn to accept sortoptions by a parameter instead of having a property.
//      The following sort options exists: mtsoCaseInsensitive and mtsoDescending.
//      mtsoPartialKey is used internally from LocateRecord where the TLocateOptions are remapped to
//      TkbmMemTableCompareOptions.
//
//1.16  Bug fixed in SaveToDataset. Close called where it shouldnt.      (19. Jul. 99)
//      Bug reported by Reinhard Kalinke (R_Kalinke@compuserve.com)
//      Fixed a few bugs + introduced Blob saving/loading in LoadFromStream/SaveToStream and thus
//      also LoadFromFile/SaveToFile. To save blob fields specify mtfSaveBlobs in save flags.
//      Full AutoInc implementation (max. 1 autoinc field/table).
//      These fixes and enhancements was contributed by Ars�ne von Wys (arsene@vonwyss.ch)
//      SetFieldData triggered the OnChange event to often. This is now fixed. Bug discovered by
//      Andrius Adamonis (andrius@prototechnika.lt).
//      Added mtfSkipRest save flag which if set will ONLY write out the fields specified by the rest of
//      the flags, while default operation is to put a marker to indicate a field skipped.
//      Usually mtfSkipRest shouldnt be specified if the stream should be reloaded by LoadFromStream later on.
//      But for generating Excel CSV files or other stuff which doesnt need to be reloaded,
//      mtfSkipRest can be valuable.
//      Greatly speeded up LoadFromStream (GetLine and GetWord).
//
//1.17  Supporting fieldtypes ftFixedChar,ftWideString.
//      Added runtime fieldtype checking for catching unsupported fields.
//      Raymond J. Schappe (rschappe@isthmus-ts.com) found a bug in CompareFields which he send a fix for.
//      Added a read only Version property.
//      The faster LoadFromStream added in 1.12 has now been removed due to the optimization of
//      the original LoadFromStream in 1.16. Tests shows no noticably performance difference anymore.
//      Inspired by Bruno Depero (bdepero@usa.net) which send me some methods for saving and
//      loading table definitions, I added mtfSaveDef to TkbmMemTableSaveFlag. If used the table
//      definition will be saved in a file. To copy another datasets definition, first do a CreateTableAs,
//      then SaveToFile/SaveToStream with mtfSaveDef.
//      Renamed TkbmSupportedFieldTypes to kbmSupportedFieldTypes and TkbmBlobTypes to kbmBlobTypes.
//      Generalized Delphi/BCB definitions.
//      Denis Tsyplakov (den@vrn.sterling.ru) suggested two new events: OnLoadField and OnLoadRecord
//      which have been implemented.
//      Added OnCompressSave and OnDecompressLoad for user defined (de)compression of SaveToStream,
//      LoadFromStream, SaveToFile and LoadFromFile.
//      Bruno Depero (bdepero@usa.net) inspired me to do this, since he send me a version including
//      Zip compression. But I like to generalize things and not to depend on any other specific
//      3. part library. Now its up to you which compression to use.
//      Added OnCompressBlobStream and OnDecompressBlobStream for (de)compression of inmemory blobs.
//      Added LZH compression to the Demo project by Bruno Depero (bdepero@usa.net).
//
//1.18  Changed SaveToStream and LoadFromStream to code special characters in string fields
//      (ftString,ftWideString,ftFixedChar,ftMemo,ftFmtMemo).
//      You may change this behaviour to the old way by setting kbmStringTypes to an empty set.
//      Fixed severe blob null bug. Blobs fields was sometimes reported IsNull=true even if
//      they had data in them.
//      Fixed a few minor bugs.
//
//1.19  Fixed a bug in CodedStringToString where SetLength was to long.             (10. Aug. 1999)
//      Bug reported by Del Piero (tomli@mail.tycoon.com.tw).
//      Fixed bug in LoadFromStream where DuringTableDef was wrongly initialized
//      to true. Should be false. Showed when a CSV file without definition was loaded.
//      Bug reported by Mr. Schmidt (ISAT.Schmidt@t-online.de)
//
//1.20  Marcelo Roberto Jimenez (mroberto@jaca.cetuc.puc-rio.br) reported a few bugs(23. Aug. 1999)
//      to do with empty dataset, which he also corrected (GetRecNo, FilterMasterDetail).
//      Furthermore he suggested and provided code for a Capacity property, which
//      can be used to preallocate room in the internal recordlist for a specific
//      minimum number of records.
//      Explicitly typecasted @ to PChar in several places to avoid problem about
//      people checking 'Typed @' in compile options.
//
//1.21  Corrected Locate on filtered recordssets.                                   (24. Aug. 1999)
//      Problem observed by Keith Blows (keithblo@woollyware.com)
//
//1.22  Corrected GetActiveRecord and added overridden SetBlockReadSize to be       (30. Aug. 1999)
//      compatible with D4/BCB4's TProvider functionality. The information and
//      code has been generously supplied by Jason Wharton (jwharton@ibobjects.com).
//      Paul Moorcroft (pmoor@netspace.net.au) added SaveToBinaryFile, LoadFromBinaryFile,
//      SaveToBinaryStream and LoadFromBinaryStream. They save/load the contents incl.
//      structure to/from the stream/file in a binary form which saves space and is
//      faster.
//      Added support for ftLargeInt (D4/D5/BCB4).
//
//1.23  Forgot to add defines regarding Delphi 5. I havnt got D5 yet, and thus      (12. Sep. 1999)
//      not tested this myself, but have relied on another person telling me that it
//      do work in D5. Let me know if it doesnt.
//      Added save flag mtfSaveFiltered to allow saving all records regardless if they are
//      filtered or not. Suggestion posed by Jose Mauro Teixeira Marinho (marinho@aquarius.ime.eb.br)
//      Added automatic resort when records are inserted/edited into a sorted table by
//      Jir� Hostinsk� (tes@pce.cz). The autosort is controlled by AutoSort flag which is
//      disabled by default. Furthermore at least one SortField must be defined for the auto
//      sort to be active.
//
//1.24  The D5 story is continuing. Removed the override keyword on BCDToCurr        (7. Oct. 1999)
//      and CurrToBCD for D5 only. Changed type of PersistentFile from String to TFileName.
//      Support for SetKey, GotoKey, FindKey inspired by sourcecode from Azuer (blue@nexmil.net) for
//      TkbmMemTable v. 1.09, but now utilizing the new internal search features.
//      Fixed bug with master/detail introduced in 1.21 or so.
//      Fixed old bug in GetRecNo which didnt know how to end a count on a filtered recordset.
//      Support for SetRange, SetRangeStart, SetRangeEnd, ApplyRange, CancelRange,
//      EditRangeStart, EditRangeEnd, FindNearest, EditKey.
//      Fixed several bugs to do with date, time and datetime fields. Now the internal
//      storage format is a TDateTimeRec.
//      Fixed problems when saving a CSV file on one machine and loading it on another
//      with different national setup. Now the following layout is allways used on
//      save and load (unless the flag mtfSaveInLocalFormat is specified on the SaveToStream/SaveToFile method,
//      in which case the local national setup is used for save. Beware that the fileformat will not be
//      portable between machines, but can be used for simply creating a Comma separated report for other
//      use):  DateSeparator:='/'  TimeSeparator:=':'  ThousandSeparator:=','  DecimalSeparator:='.'
//      ShortDateFormat:='dd/mm/yyyy' CurrencyString:='' CurrencyFormat:=0 NegCurrFormat:=1
//      Date problems reported by Craig Murphy (craig@isleofjura.demon.co.uk).
//      We are getting close to have a very complete component now !!!
//
//1.25  Added CompareBookmarks, BookmarkValid, InternalBookmarkValid by             (11. Oct. 1999)
//      Lars S�ndergaard (ls@lunatronic.dk)
//
//1.26  In 1.24 I introduced a new keybuffer principle for performance and easyness.(14. Oct. 1999)
//      Unfortunately I forgot a few things to do with Master/Detail. They have now
//      been fixed. Problem reported by Dirk Carstensen (D.Carstensen@FH-Wolfenbuettel.DE)
//      He also translated all string ressources to German.
//      Simply define the localization type wanted further down and recompile TkbmMemTable.
//      Fixed AutoSort problem when AutoSort=true on first record insert.
//      Further more setting AutoSort=true on a nonsorted dataset will result in an
//      automatic full sort on table open.
//      Problem reported by Carl (petrolia@inforamp.net)
//      Added events OnSave and OnLoad which are called by SaveToDataSet,
//      SaveToStream, SaveToBinaryStream, SaveToFile, SaveToBinaryFile,
//      LoadFromDataSet, LoadFromStream, LoadFromBinaryStream,
//      LoadFromFile, LoadFromBinaryFile. StorageType defines what type of save/load
//      is going on: mtstDataSet, mtstStream, mtstBinaryStream, mtstFile and mtstBinaryFile.
//      Stream specifies the stream used to save/load. Will be nil if StorageType is mtstDataSet.
//
//1.27  In 1.26 I unfortunately made 2 errors... Forgot to rename the german ressource file's (19. Oct. 1999)
//      unitname and made another autosort problem. Things are going a bit fast at the moment,
//      thus it is up to you all to test my changes :)
//      Well..well... the german ressourcefile's unitname is now correct.
//      AutoSort is now working as it should. Been checking it :)
//      And its pretty fast too. Tried with 100.000 records, almost immediately
//      on a PII 500Mhz.
//      Added autosort facilities to the demo project and posibility to change
//      number of records in sample data. Tried with 1 million records... and it works :)
//      although quicksort is not the optimal algorithm to use on a very unbalanced
//      large recordset. It seems to be fast enough for around 10.000 records.
//      (almost immediately on a PII 500Mhz.)
//      Published SortOptions, and added SortDefault to do a sort using the published
//      sortfields and options. Mind you that Sort(...) sets up new sortoptions.
//
//1.28  Added PersistentSaveOptions.                                                 (21. Oct. 1999)
//      Added PersistentSaveFormat either mtsfBinary or mtsfCSV.
//      Fixed some flaws regarding persistense in designmode which could lead to loss of
//      data in the persistent file and loss of field definitions.
//
//1.29  I. M. M. VATOPEDIOU (monh@vatopedi.thessal.singular.gr) found a bug in GetRecNo (22. Oct. 1999)
//      which he send a fix for.
//
//1.30  Fernando (tolentino@atalaia.com.br) send OldValue enhancements and thus introduced
//      InternalInsert, InternalEdit, InternalCancel procedures.
//      Furthermore he suggested to rename TkbmMemTable to TkbmCustomMemTable and descend TkbmMemTable from it.
//      I decided to follow his suggestion as to make it easier to design own memory table children.
//      Kanca (kanca@ibm.net) send me example on runtime creation of TkbmMemTable. The example
//      has been put in the demo project as a comment.
//      Holger Dors (dors@kittelberger.de) suggested a version of CompareBookmarks which guarantiees
//      values -1, 0 or 1 as result. This has now been implemented.
//      Furthermore he retranslated an incorrect German translation for FindNearest.
//
//1.31  SetRecNo and GetRecNo has been analyzed carefully and rewritten to      (26. Oct. 1999)
//      reflect normal behaviour. Locate was broken in 1.29 because of the prev.
//      GetRecNo fix. Reported by Carl (petrolia@inforamp.net).
//      There have been significant speedups in insert record and delete record.
//      Now TkbmMemTable contains a componenteditor for D5. Source has been donated by
//      Albert Research (albertrs@redestb.es) and partly changed by me.
//      Ressourcestrings has been translated to French by John Knipper (knipjo@altavista.net)
//      Removed InternalInsert for D3. Problem reported by John Knipper.
//
//1.32  Fernando (tolentino@atalaia.com.br) sent Portuguese/Brasillian translation. (5. Nov. 1999)
//      Vasil (vasils@ru.ru) sent Russian translation.
//      Javier Tari Agullo (jtari@cyber.es) sent Spanish translation.
//      Tero Tilus (terotil@cc.jyu.fi) suggested to save the visibility flag of a field too
//      along with all the other fielddefinitions in the SaveToStream/LoadFromStream etc. methods.
//      I changed CreateTableAs format to:
//        procedure CreateTableAs(Source:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions);
//      where copyoptions can be:
//        mtcpoStructure         - Copy structure from the source datasource.
//        mtcpoOnlyActiveFields  - Only copy structure of active fields in the source datasource.
//        mtcpoProperties        - Also copy field info like DisplayName etc. from the source datasource.
//        mtcpoLookup            - Also copy lookup definitions from the source datasource.
//        mtcpoCalculated        - Also copy calculated fielddefinitions from the source datasource.
//      or a combination of those values in square brackets [...].
//      Further LoadFromDataSet is now following the same syntax.
//      A new method CreateFieldAs has been appended used by CreateTableAs.
//      Lookup fields defined in the memorytable now works as expected.
//      Now the designer will show all types of database tables, not only STANDARD.
//      Changed CopyRecords to allow copying of calculated data, and not clearing out
//      lookup fields on destination.
//      Fixed autosort error reported by Walter Yu (walteryu@21cn.com).
//
//1.33  Fixed error in CopyRecords which would lead to wrongly clearing calculated fields  (23. Nov. 1999)
//      after they have correcly been set.
//      Fixed problem with autosort when inserting record before first.
//      Fixed exception problem with masterfields property during load. Problem
//      reported by Jose Luis Tirado (jltirado@jazzfree.com).
//      Fixed a few errors in the demo application.
//      Added Italian translation by Bruno Depero (bdepero@usa.net).
//
//1.34  Fixed Resort problem not setting FSorted=true. Problem reported by     (3. Dec. 1999)
//      Tim_Daborn@Compuserve.com.
//      Added Slovakian translation by Roman Olexa (systech@ba.telecom.sk)
//      Added Romanian translation by Sorin Pohontu (spohontu@assist.cccis.ro)
//      Fixed problem about FSortFieldList not being updated when new sortfields are defined.
//      The fix solves the AutoSort problem reported by Sorin Pohontu (spohontu@assist.cccis.ro)
//      Javier Tari Agullo (jtari@cyber.es) send a fix for Spanish translation.
//      Added threaded dataset controller (TkbmThreadDataSet).
//      Put it on a form, link the dataset property to a dataset.
//      When you need to use a dataset, do:
//
//      ds:=ThreadDataset.Lock;
//      try
//         ...
//      finally
//         ThreadDataset.Unlock;
//      end;
//
//1.35  LargeInt type handling changed. Now it will be read and saved          21. Dec. 1999
//      as a float, not as an integer. General fixes to do with LargeInt field
//      types. Bug reported by Fernando P. N�jera Cano (j.najera@cgac.es).
//      Fixed bug reported by Urs Wagner (Urs_Wagner%NEUE_BANKENSOFTWARE_AG@raiffeisen.ch)
//      where a field could be edited even if no Edit or Insert statement has been issued.
//      Jozef Bielik (jozef@gates96.com) suggested to reset FRecNo and FSorted when
//      last record is deleted in _InternalDelete. This has been implemented.
//
//1.36  Edison Mera Men�ndez (edmera@yahoo.com) send fix for bug in autoupdate. 23. Dec. 1999
//      Further he send code for a faster resort based on binary search for
//      insertionpoint instead of the rather sequential one in the previous version.
//      In case of problems, the old code can be activated by defining ORIGINAL_RESORT
//      He also suggested and send code for an unified _InternalSearch which does the
//      job of selecting either sequential or binary search.
//      Brad - RightClick (brade@rightclick.com.au) suggested that autosort should be
//      disengaged during load operations. I agree and thus have implemented it.
//      Implemented that EmptyTable implecitely does a cancel in case the table
//      was in Edit mode. Suggested by Albert Research (albertrs@redestb.es).
//
//1.37  Claude Rieth from Computer Team sarl (clrieth@team.lu) suggested to be able to 3. Jan. 2000
//      specify save options for CommaText. Thus CommaTextOptions has been added.
//      Several people have been having trouble installing in BCB4. The reason is
//      that some unused 3.rd party libraries sneeked into the TkbmMemTable
//      BCB4 project file. It has been fixed.
//      Bookmark handling has been corrected. Problem reported by Dick Boogaers (d.boogaers@css.nl).
//      InternalLoadFromBinaryStream has been fixed with regards to loading a NULL date.
//      A date is considered NULL when the value of the date is 0.0 (1/1/1899).
//      Problem reported by Paul Moorcroft (pmoor@netspace.net.au)
//      Ohh.. and HAPPY NEWYEAR everybody! The world didnt vanish because of 2 digits.
//      Isnt that NICE !! :)
//
//2.00a BETA First beta release.
//      CompareBookmark corrected to handle nil bookmark pointers by             5. Jan. 2000
//      jozef bielik (jozef@gates96.com)
//      Indexes introduced. AddIndex,DeleteIndex,IndexDefs supported.
//      AutoSort removed, Resort removed, Sort and SortOn now emulated via an internal index
//      named __MT__DEFSORT__.
//      Indexes introduced as a way into the internal indexes. Not really needed by most.
//      EnableIndexes can be set to false to avoid updating the indexes during a heavy load
//      operation f.ex. The indexes will be invalid until next UpdateIndexes is issued.
//      mtfSaveIndexDef added to possible save flags.
//      Save formats changed for both CSV files and binary files. For reading v.1.xx
//      files, either use CSV format or for binary files, set the compatibility
//      definition further down. V. 1.xx will NOT be compatible with files written
//      in v.2.xx format unless no table definitions are written.
//      _InternalSearch, _InternalBinarySearch and _InternalSequentialSearch removed.
//      ftBytes fieldtype corrected. Usage is shown in the demo project.
//
//2.00b BETA Fixed D4 installation problem reported by Edison Mera Men�ndez (edmera@yahoo.com).
//      Published IndexDefs.
//      Added support for ixUnique.
//      Thomas Everth (everth@wave.co.nz) fixed two minor issues in LoadFromDataSet and
//      SaveToDataSet. Further he provided the protected method UpdateRecords, and the
//      public method UpdateToDataset which can be used to sync. another dataset with
//      the contents of the memorytable.
//      Fixed lookup to correcly handle null or empty keyvalues.
//
//2.00c BETA Renamed IndexFields to IndexFieldNames. Supporting IndexName.
//      Fixed designtime indexdefinitions wouldnt be activated at runtime.
//      Fixed Sort/SortOn would generate exception. Fixed Sort/SortOn on blob
//      would generate exception.
//
//2.00d BETA Fixed Master/Detail.
//      Changed the internal FRecords TList to a double linked list to make
//      deletes alot easier from the list. FRecords have been superseeded by
//      FFirstRecord and FFLastRecord. Changed the recordstructure. Introduced
//      TkbmRecord and PkbmRecord which is the definition of a record item.
//      Fixed SwitchToIndex to maintain current record the same after a switch.
//      Added notification handling to reflect removal of other components.
//      Added support for borrowing structures from another TDataset in the
//      table designer.
//
//2.00e BETA Changed bookmark functionality.
//      Fixed D4 installation.
//      Fixed index updating.
//      Optimized indexing and bookmark performance.
//      Added record validity check.
//      Still some bookmark problems.
//
//2.00f BETA Removed the double linked list idea from 2.00d. Back to a TList.
//      Reason is the bookmark handling is not easy to get to work with pointers,
//      plus its needed to be able to delete a record without actually removing
//      it from the 'physical' database. Thus PackTable has been introduced.
//      Deleting a record actually frees the recordcontents, but the spot in
//      the TList will not be deleted, just marked as deleted (nil). PackTable removes
//      all those empty spots, but at the same time invalidates bookmarks.
//      EmptyTable does what the name says, empty it including empty spots and
//      records as allways. Result should be that bookmarks are working as they
//      should, and GotoBookmark is very fast now.
//      Empty spots will automatically be reused when inserting new records
//      by the use of a list of deleted recordID's, FDeletedRecords.
//      Protected function LocateRecord changed.
//      Locate changed, Lookup behaviour improved.
//      CancelRange behaviour improved.
//
//2.00g BETA Fixed edit error when only 1 record was left and indexes defined.
//      Problem reported by Dick Boogaers (d.boogaers@css.nl).
//      Fixed error occuring when inserting records in an empty memtable with
//      a unique index defined.
//      Fixed error when altering a field which is indexed to a value bigger than
//      biggest value for that field in the table.
//
//2.00h BETA Added IndexFields property as suggested by Dick Boogaers (d.boogaers@css.nl).
//
//2.00i BETA Added AttachedTo property for having two or more views on the
//      physical same data. Updating one table will show immediately in the others.
//      Fielddefinitions will be inherited from the primary table holding the data.
//      There can only be one level of attachments. Eg. t2 can be attached to t1,
//      but then t3 can't be attached at t2, but must be directly attached to t1.
//      Its possible to have different indexes on the tables sharing same data.
//      Fixed SearchRecordID problem which sometimes didnt find the record even
//      if it definitely existed. The reason and solution is explained in the
//      SearchRecordID method.
//      Made TkbmCustomMemTable threadsafe.
//      ftArray and ftADT support added by Stas Antonov (hcat@hypersoft.ru).
//
//2.00j BETA Changed to not check for disabled controls on DisableControls/EnableControls
//      pairs. Fixed wrong call to _InternalEmpty in InternalClose when an attached
//      table close. Thread locking changed and fixed.
//      New property AttachedAutoRefresh. Set to false to disallow the cascading refreshes
//      on dataaware controls connected to all the attached memorytables.
//
//2.00k BETA Made public properties on TkbmIndex:
//      IsOrdered:boolead It can be used to determine if the index is up to date.
//      Or it can be set to true to force that the index must be percieved as up to date,
//      even if it hasnt been fully resorted since creation. Usefull f.ex. when loading
//      data from a presorted file. Eg.:
//      mt.EnableIndexes:=false;
//      mt.LoadFromFile(...);
//      mt.EnableIndexes:=true;
//
//      // Since the data was saved using the index named 'iSomeIndex' and thus loaded
//      // in the right sortorder, dont reupdate the iSomeIndex index.
//      mt.Indexes.Get('iSomeIndex').IsOrdered:=true;
//
//      // At some point, update all nonordered indexes.
//      mt.UpdateIndexes;
//
//      IndexType:TkbmIndexType Should only be used to determine the indextype. Dont set.
//      CompareOptions:TkbmMemTableCompareOptions Should only be used to determine the compare options.
//      Dont set.
//      IndexOptions:TIndexOptions Should only be used to determine the indexoptions. Dont set.
//      IndexFields:string Should only be used to determine the fields in the index. Dont set.
//      IndexFieldList:TList Should only be used to gain access to a list of TField objects
//      of fields participating in the index. Dont alter or set.
//      Dataset:TkbmCustomMemTable Should only be used to determine the dataset on which the
//      index is created. Dont set.
//      Name:string Should only be used to determine the name used during creation of the index.
//      Dont set.
//      References:TList References to the records. The references are sorted in the way the index defines.
//      IsRowOrder:boolean Used to determine if this index is a row order index. (the order the records
//      are inserted).
//      IsInternal:boolean Used to determine if this index is an internal index (used by SortOn f.ex.)
//      IndexOfs:integer Used to determine what position this index have in the TkbmIndexes list.
//      Fixed ftBytes bug reported by Gianluca Bonfatti (gbonfatti@libero.it).
//
//2.01  FINAL Cosmin (monh@vatopedi.thessal.singular.gr) reported some problems
//      and came up with some fixes. I have loosely followed them to solve the problems.
//      a) Fixed loading data into readonly fields using LoadFrom...
//      Developers can use new 'IgnoreReadOnly' public property if they want to
//      update fields which are actually defined as readonly. Remember to
//      set it to false again to avoid users updating readonly fields.
//      b) Fixed readonly on table level.
//      c) New read only property: RangeActive:boolean. True if a range is set.
//      d) Fixed autoinc. fields.
//      Fixed bogus warning about undefined return from SearchRecordID.
//
//2.01a Fixed wrong use of FBufferSize in PrepareKeyRecord. Should be FRecordSize;
//
//2.10  Now complete support for Filter property!
//
//2.11  The filter property is only supported for D5. IFDEF's inserted to maintain
//      backwards compatibility.
//      Support for a UniqueRecordID which allways will increase on each insert
//      in contrast to RecordID which is not unique through the lifetime of
//      a memorytable (eg. reusing deleted record spots).
//      Support for RecordTag (longint) which can be used by any application to fill
//      extra info into the record for own use without having to create a real
//      field for that information. Remember that the application is responsible
//      for freeing memory pointed to by this tag (if thats the way its used).
//      Added mtfSaveIgnoreRange and mtfSaveIgnoreMasterDetail to solve problem reported
//      by monh@vatopedi.thessal.singular.gr that saving data during master/detail
//      or ranges will only save 'visible' records.
//
//2.20  NOTE!!!!!   !!!!   !!!!!  NEW LICENSE AGREEMENT  !!!! PLEASE READ !!!!!
//      Fixed quite serious bug in PrepareKeyRecord which would overwrite    16. Feb. 2000
//      memory. Problem occured after using one of the SetKey, EditKey, FindKey,
//      GotoKey, FindNearest methods.
//      Enhanced record validation scheme. Can now check for memory overruns.
//      Changed the inner workings of FindKey and FindNearest a little bit.
//      Fixed that if an IndexDef was specified without any fields, an exception will
//      be raised.
//      Added CopyBlob boolean flag to _InternalCopyRecord which if set, also
//      duplicates all blobs in the copy. Remember to _InternalFreeRecord with
//      the FreeBlob boolean flag set for these copies.
//      Added journaling functionality through the new properties
//      Journal:TkbmJournal, EnableJournal:boolean, IsJournaling:boolean and
//      IsJournalAvailable:boolean. The journaling features are inspired by
//      CARIOTOGLOU MIKE (Mike@singular.gr).
//
//2.21  Fixed backward compatibility with Delphi 3.
//
//2.22  Fixed Sort and SortOn problem with CancelRange.
//      Fixed compile problem when defining BINARY_FILE_1_COMPATIBILITY.
//
//2.23  Fixed several bugs in TkbmCustomMemTable.UpdateIndexes which would
//      lead to duplicate indexdefinitions on every update, which again would
//      lead to the infamous idelete<0 bug.
//      Inserted several checks for table being active in situations where
//      indexes are modified.
//
//2.24  Fixed bug reported by Jean-Pierre LIENARD (jplienard@compuserve.com)
//      where Sort/SortOn called 2 times around a close/open pair would lead
//      to AV. InternalClose now deletes a sortindex if one where created.
//      Thus Sort/SortOn are only temporary (as they were supposed to be in
//      the first place anyway :)
//      Fixed small filtering bug.
//
//2.30a ALPHA Fixed bug in BinarySearch. Before it correctly found a matching record
//      but it was not guranteed the first available record matching. Now it
//      backtracks to make sure its the first one in the sortorder which matchs.
//      Fixed old problem when persistent tables are not written on destruction
//      of the component.
//      Fixed GetByFieldNames (use to find an index based on fieldnames) to be
//      case insensitive.
//      Journal is now freed on close of table, not destruction.
//      Fixed bug in _InternalCompareRecords which would compare with one field
//      to little if maxfields were specified (noticed in some cases in M/D
//      setups).
//      Changed internals of _InternalSaveToStream and _InternalSaveToBinaryStream.
//      Support for versioning implemented. Support for saving deltas using
//      SaveToBinary... supported using flag mtfSaveDeltas.
//      Resolver class (TkbmCustomDeltaHandler) for descending from to
//      make delta resolvers.
//      Added StartTransaction, Commit, Rollback as virtual methods for local
//      transaction handling. Override these to handle middleware transactions.
//      Added readonly TransactionLevel which shows the level of the current
//      transaction.
//      CARIOTOGLOU MIKE (Mike@singular.gr) came up with a big part of the versioning code
//      and had several suggestions to how to handle deltas and versioning.
//
//2.30b BETA Added checking for empty record in list of records in several places (lst.items[n]=nil)
//      Added new save flag mtfSaveDontFilterDeltas which if not specified, filters out
//      all records which has been inserted and then deleted again within the same session.
//      (A session understood like from load of records to save of them).
//      Added new property AllData which can be read to get a variant containing all data
//      and be set from a variant to load all data from.
//      Added new property AllDataOptions which defines which data will be saved using the
//      AllData property. Suggested by CARIOTOGLOU MIKE (Mike@singular.gr).
//      Added designtime persistense of data on form by the new property StoreDataOnForm.
//      If a designtime memtable contains data and thus is active, setting StoreDataOnForm:=true
//      and saving the form will save the data on the form. Thus the data will be available
//      when the form is loaded next time aslong the memtable is active (opened).
//      Added Czech translation by Roman Krejci (info@rksolution.cz)
//      Added property IsFieldModified(i:integer):boolean for checking if a field has been modified.
//      The status is only available until Cancel or Post. Suggested by Alexandre DANVY (alex-dan@ebp.fr)
//      Tabledesigner layout fixed.
//
//2.30c BETA Added two generaly available procedures:                        3. Mar. 2000
//      StreamToVariant and VariantToStream which handles putting a stream into
//      a variant and extracting it again. Means its possible to store f.ex a complete
//      file in a variant by opening the file with a TFileStream and pass the stream
//      through StreamToVariant.
//      Added example of transactioning to the demo project.
//      Added support for TField.DefaultExpression (default value for each field).
//      Define DO_CHECKRECORD to call _InternalCheckRecord. Was default before.
//      Normally only to be used in debug situations.
//      Applied some performance optimizations.
//
//2.30  FINAL Fixed before close bug which would clear a persistent file
//      if the programmer called close before destroy. Problem reported by
//      Frans Bouwmans (fbouwmans@spiditel.nl)
//      Fixed clear index bug not resetting FSortIndex. Problem reported by
//      Ronald Eckersberger (TeamDM) (ron@input.at)
//      Published AutoCalcFields.
//      Added property: RecalcOnFetch (default true) which regulates if
//      calculated fields should be recalced on each fetch of a record or not.
//      Fixed resetting AttachedTo when parent table is destroyed.
//
//2.31  Fixed D3 compatibility.
//      Fixed Resolver. OrigValues as record at checkpoint, Values as
//      record in current version.
//      Fixed missing resync in FindNearest reported by
//      Alexander V. Miloserdov (tatco@cherkiz.spb.su).
//
//2.32  Fixed TkbmCustomMemTable.DeleteIndex A/V bug in D4. Problem reported
//      by Alexander V. Miloserdov (tatco@cherkiz.spb.su).
//
//2.33  Refixed again FindNearest. This time it works ;)
//
//2.34  Fixed missing filter in SaveTo.... Problem reported by Alexei Smirnov (alexeisu@kupol.ru)
//      Fixed missing use of binary search. Problem reported by Tim Daborn (Tim_Daborn@Compuserve.com)
//      Data persistency on destruction of component fixed. Fix by Cosmin (monh@vatopedi.thessal.singular.gr)
//      UpdateRecord fixed with regards to only one key field specified.
//      Fix by Marcello Tavares (TAVARES@emicol.com.br)
//      Brazilian ressource file changed by Marcello Tavares (TAVARES@emicol.com.br).
//      Added KBM_MAX_FIELDS which can be changed to set max. number of fields
//      to handle in a table. Default 256.
//      Fixed bug in error message when unsupported field added to fielddef.
//      Problem reported by Alexandre Danvy (alex-dan@ebp.fr)
//      Fixed some bugs regarding SetRangeStart/End EditRangeStart/End and ApplyRange.
//      Remember to set IndexFieldNames to an index to use including the fields used for the range.
//      Better is to use a filter or similar.
//
//2.35  Fixed bug not clearing out indexes on table close.
//
//2.36  Fixed bug in DeleteIndex which would not reset FCurIndex correctly.   30. mar. 2000
//      Problem seen when SortOn or Sort would be called many times.
//      Problem reported by Michail Haralampos (Space Systems) (spacesys@otenet.gr)
//      Changed CreateTableAs to not to update fielddefs while source table is allready
//      active for compatibility with a bug in Direct Oracle Access. Problem
//      reported by Holger Dors (dors@kittelberger.de)
//      Changed handling of oldrecord and current record during an edit of a record to
//      correctly cancel changes to a blob. Problem reported by Ludek Horcicka (ludek.horcicka@bcbrno.cz)
//
//2.37  Fixed A/V bug versioning blobfields. Problem reported by Jerzy Labocha (jurekl@geocities.com).
//      Optimized indexing when record edited which does not affect index.
//      Suggested by Lou Fernandez (lfernandez@horizongt.com).
//      Fixed bug in InternalLoadFromBinary where check for ixNonMaintained was in wrong order
//      compared to savetobinary.
//      Fixed bug in InternalLoadFromBinary where indexes was created and marked
//      as updated prematurely. Problem reported by Jerzy Labocha (jurekl@geocities.com).
//      Changed LoadFromDataSet to allow copy of properties from default fields.
//      Problem reported by Tim Evans (time@cix.compulink.co.uk).
//
//2.38  Fixed bug not correctly determining autoinc value on loading binary file.
//      Problem and fix reported by Jerzy Labocha (jurekl@geocities.com).
//      Fixed small bug in SaveToStream where nil records would risc being saved.
//      Fixed bug in SetRecNo reported by Mike Cariotoglou (Mike@singular.gr).
//      Added RespectFilter on TkbmIndex.Search and TkbmIndexes.Search for Locate etc. to
//      respect filters set. Problem reported by Andrew Leiper (Andy@ietgroup.com).
//      Added to index search routines to make them threadsafe.
//      Fixed bug updating indexes of attached tables on edit of master table.
//      Problem reported by Lou Fernandez (lfernandez@horizongt.com).
//      Added CSV delimiter properties: CSVQuote, CSVFieldDelimiter, CSVRecordDelimiter
//      which are all char to define how CSV output or input should be handled.
//      CSVRecordDelimiter can be #0 to not insert a recorddelimiter. Note that
//      #13+#10 will be inserted at all times anyway to seperate records.
//      Fixed bug in _InternalClearRecord and added new protected method
//      UnmodifiedRecord in TkbmCustomDeltaHandler.
//      Changed algorithm of dsOldRecord to return first version of record.
//      Added 3 new public medium level functions:
//        function GetVersionFieldData(Field:TField; Version:integer):variant;
//        function GetVersionStatus(Version:integer):TUpdateStatus;
//        function GetVersionCount:integer;
//      which can be used to obtain info about previous versions of current record.
//      GetVersionCount get number of versions of current record. Min 1.
//      GetVersionFieldData gets a variant of data of a specific version. Current
//      record version (newest) is 0.
//      GetVersionStatus returns the TUpdateStatus info of a specific version. Current
//      record version (newest) is 0.
//      Inspiration and fixes by Mike Cariotoglou (Mike@singular.gr).
//
//2.39  Fixed bug setting Filtered while Filter is empty.
//      Fixed autoinc bug on attached tables reported by Jerzy Labocha (jurekl@geocities.com).
//      Added GetRows function for getting a specified number of rows at a starting point
//      and return them as a variant. Code contributed by Reinhard Kalinke (R_Kalinke@compuserve.com)
//      Added integer property LoadLimit which will limit the number of records loaded using LoadFrom....
//      methods. Suggested by Roman Olexa (systech@ba.telecom.sk). if LoadLimit<=0 then
//      no limit is imposed.
//      Added read only integer property LoadCount which specifies how many records
//      was affected in last load operation.
//      Added read only boolean property LoadedCompletely which is true if all data was loaded,
//      false if the load was interrupted because of LoadLimit.
//      Fixed LoadFrom.... to not load into non data fields. Fix by cosmin@lycosmail.com.
//      Fixed persistency on destruction of component.
//      Added partial Dutch ressourcefile by M.H. Avegaart (avegaart@mccomm.nl).
//      Added method Reset to clear out data, fields, indexes and more by kanca@ibm.net.
//      LoadFromBinaryStream/File now tries to guess approx. how many records will be loaded
//      and thus adjust capacity accordingly.
//      Improved persistent save to not delete original file before finished writing new.
//      Suggested by Paul Bailey (paul@cirrlus.co.za).
//      Fixed minor bug in GetRecordCount when table not active by Csehi Andras (acsehi@qsoft.hu)
//
//2.40  Fixed problem with SetRange specifying fewer fields than number of index fields, giving   12. May. 2000
//      wrong number of resulting records. Problem reported by Jay Herrmann (Jayh@adamsbusinessforms.com)
//      Added new AddIndex2 method to TkbmCustomMemTable which allows to define some additional indexsetups:
//        mtcoIgnoreLocale   which use standard CompareStr instead of AnsiCompareStr.
//        mtcoIgnoreNullKey  which specifies that a null key field value will be ignored in record comparison.
//      Except for the ExtraOptions parameter its equal in functionality to AddIndex.
//      Added new property: OnCompareFields which can be used to handle specialized sortings and searches.
//      Made the following functions publicly available:
//           function CompareFields(KeyField,AField:pointer; FieldType: TFieldType; Partial, CaseInsensitive,IgnoreLocale:boolean):Integer;
//           function StringToCodedString(const Source:string):string;
//           function CodedStringToString(const Source:string):string;
//           function StringToBase64(const Source:string):string;
//           function Base64ToString(const Source:string):string;
//      Added new property: AutoIncMinValue which can be used to set startvalue for autoinc. field.
//      Added new property: AutoIncValue which can be used to obtain current next value for an autoinc field.
//
//2.41  Fixed problem regarding calculated fields on attached table not updating. Problem
//      reported by aZaZel (azazel@planningsrl.it).
//
//2.42  Added PersistentBackup:boolean and PersistentBackupExt:string which controls if to make  25. May. 2000
//      a backup of the previous persistent file and which extension the file should have.
//      Code provided by cosmin@lycosmail.com.
//      Made ResetAutoInc public. Suggested by cosmin@lycosmail.com.
//      Fixed missing copy of RecordTag in InternalCopyR*. Reported by Alexey Trizno (xpg@mail.spbnit.ru).
//      Added property groups by Chris G. Royle (cgr@dialabed.co.za).
//      Fixed missing reset of UpdateStatus in _InternalClearRecord. Reported by CARIOTOGLOU MIKE (Mike@singular.gr)
//      Fixed Search bug on empty table. Problem seen inserting into empty table with ixunique index defined.
//      Problem reported by George Tasker (gtasker@informedsources.com.au)
//      Published BeforeRefresh and AfterRefresh.
//      Fixed deactivation of designed active table during runtime. Reason was missing inherited
//      in Loaded method. Problem reported by John McLaine (johnmclaine@hotmail.com)
//
//2.43  Added OnProgress event which will fire on long operations notifying how
//      many percent has been accomplished. The operation performed can be
//      found in the Code parameter.
//      Added new FastQuickSort procedure to TkbmIndex. Enhances searchspeed by
//      somewhere around 50-75%. Sorting 100.000 records on a field on a PII 450Mhz
//      now takes approx 5 secs. FastQuickSort (combination of a modified Quicksort and
//      Insertion sort) is now the default sorting mechanism.
//      To reenable the previous standard Quicksort mechanism, put a comment on the
//      USE_FAST_QUICKSORT definition further down.
//      Danish translation of ressource strings added.
//      Added public low level function GetDeletedRecordsCount:integer.
//      Changed master/detail behaviour to allow more indexfields than masterfields.
//      Change proposed seperately by Thomas Everth (everth@wave.co.nz) and
//      IMB Tameio (vatt@internet.gr)
//      Updated Brasilian translation by Eduardo Costa e Silva (SoftAplic) (eduardo@softaplic.com.br)
//      Added protected procedure PopulateBlob by Fernando (tolentino@atalaia.com.br)
//      Fixed issues compiling in D3 and BCB4.
//      Commented out not copying nondatafields in LoadFromDataset as implemented in v.2.39
//      Problem reported by Roman Olexa (systech@ba.telecom.sk).
//
//2.44  Removed stupid bug I implemented in 2.43. Forgot to remove some code.
//      Fixed the demo project handling range. The demo of the SetRange function
//      forgot that no index named 'Period' was defined, thus the range was set
//      on the currently active index instead.
//      Added support for using SortOn('',....) for selecting the roworder index.
//      Defined some consts for internal indexnames and internal journal field names.
//        kbmRowOrderIndex = '__MT__ROWORDER'
//        kbmDefSortIndex  = '__MT__DEFSORT'
//        kbmJournalOperationField  = '__MT__Journal_Operation'
//        kbmJournalRecordTypeField = '__MT__Journal_RecordType'
//
//2.45  Fixed Master/detail problem setting masterfields while table not active.
//      Problem reported by CARIOTOGLOU MIKE (Mike@singular.gr).
//      Fixed Filter expression problem when reordering fields in runtime.
//      Problem reported by houyuguo@21cn.com.
//      Added several more progress functions.
//      Added TableState which can be polled to decide whats going on in the table at
//      the moment.
//      Added AutoReposition property (default false) which determines if automatically
//      to reposition to new place for record on record post, or to stay at current pos.
//      Fixed dupplicate fieldname problem with attached tables as reported by
//      Roman Olexa (systech@ba.telecom.sk). If fieldnames conflict between the
//      current table and the table attached to, the original current table field
//      is removed from the table, and the attached to table field used instead.
//
//2.45b Fixed missing FOrdered:=true on FastQuicksort. Problem reported
//      by Tim  Daborn (Tim_Daborn@Compuserve.com)
//
//2.46  Fixed SetFilterText bug. Problem reported by Anders Thomsen (thomsenjunk@hotmail.com)
//      Added BCB 5 support by Lester Caine (lester@lsces.globalnet.co.uk)
//
//2.47  Added copy flag mtcpoAppend for appending data using LoadFromDataset.
//      Added Master/Detail designer. Corrected master/detail functionality.
//      Added Hungarian translation by Csehi Andras (acsehi@qsoft.hu)
//
//2.48  Fixed InternalSaveToStream to save in current indexorder. Problem reported
//      by Cosmin (vatt@internet.gr) and Christoph Ansermot (info@illuminati.ch)
//      Fixed InternalAddRecord to respect the Append flag. Problem reported by
//      Milleder Markus (QI/LSR-Wi) (Markus.Milleder@tenovis.com)
//      Fixed filter bug < which was considered the same as <=. Bug reported by
//      Milleder Markus (QI/LSR-Wi) (Markus.Milleder@tenovis.com)
//
//2.49  Fixed TkbmIndexes.Clear leaving an invalid FSortIndex.      16. July 2000
//      Problem fixed by Jason Mills (jmills@sync-link.com).
//      Fixed D3 bugs which wouldnt allow to compile. Problem fixed by
//      Speets, RCJ (ramon.speets@corusgroup.com)
//      Changed ftVarBytes to work similar to ftBytes. Problem reported by
//      mike cariotoglou (Mike@singular.gr)
//      Fixed filtering of strings through the Filter property. Problem reported
//      by several.
//      Modified demoproject with FindKey functionality and string field.
//      For the time being, removed support for the WideString fieldtype.
//      Changed SaveToBinaryxxxxx to save in the order of the current index.
//      Beware that if the current index is not up to date, it could mean
//      saving less records than there actually is in the table.
//      Changed binary file format to include null value info. LoadFromBinaryxxx
//      is backwards compatible, but files saved with SaveToBinaryxxxx can only
//      be read by software incoorporating TkbmMemTable v. 2.49 or newer.
//      If needed, one of the BINARY_FILE_XXX_COMPATIBILITY defines can be
//      specified for saving in a format compatible with older versions of
//      TkbmMemTable.
//
//2.50  Fixed bug on SortOn after UpdateIndexes. Problem reported by Gate (x_gate@hotmail.com)
// a-d  Added IndexByName(IndexName:string) property to obtain a TkbmIndex object for
// Beta the specified indexname.
//      Added Enabled property to TkbmIndex which can be set to false to disable
//      updating that index or true to allow updating again. An automatic rebuild
//      is issued if needed.
//      Fixed incorrect definition of properties EnableVersioning and VersioningMode
//      in TkbmMemTable. Problem reported by U. Classen (uc@dsa-ac.de)
//      Made CopyRecords public and changed it to copy from current pos in source.
//      Fixed counter bug in CopyRecords which would copy one record more than limit.
//      Fix suggested by Wilfried Mestdagh (wilfried_sonal@compuserve.com).
//      Added saveflag mtfSaveAppend which will append the current dataset to
//      the data previously saved in the file or stream. Suggested
//      by Denis Tsyplakov (den@icsv.ru)
//      Fixed AutoInc problem using InsertRecord/AppendRecord as reported by
//      Jerzy Labocha (jurekl@ramzes.szczecin.pl)
//      Fixed D3 inst. by replacing TField.FullName for TField.FieldName for
//      level 3 installations only. Problem reported by Marcel Langr (mlangr@ivar.cz)
//      Fixed cancel/Blob bug. Pretty tuff to fix. Several routines heavily
//      rewritten to solve problem. Those changes also allows for better strings
//      optimization.
//      Fixed bug reported by jacky@acroprise.com.tw in SwitchToIndex on empty table.
//      Fixed autoreposition bug by CARIOTOGLOU MIKE (Mike@singular.gr).
//      Fixed attachedto bug during destroy by Vladimir Piven (grumbler@ekonomik.com.ua).
//      Optimized per record memory usage by compiling out the debug values startident and endident
//      + made record allocation one call to getmem instead of two. Suggested by
//      Llu�s Oll� (mailto:llob@menta.net)
//      Added Performance property which can hold mtpfFast, mtpfBalanced or mtpfSmall.
//      Meaning:
//        mtpfFast=One GetMem/Rec. No recordcompression.
//        mtpfBalanced=One or more GetMem/Rec. Null varlength fields are compressed.
//        mtpfSmall=Like mtpfBalanced except varlength field level compression is made.
//      Use mtpfFast if all string values will have a value which are close to the
//      max size of the string fields or raw speed is important.
//      Use mtpfBalanced if most string fields will be null.
//      Use mtpfSmall in other cases.
//      Added OnCompressField and OnDecompressField which can be used to
//      create ones own field level compression and decompression for all nonblob
//      varlength fields. For blobfields checkout OnCompressBlob and OnDecompressBlob.
//      Added OnSetupField which can be used to overwrite indirection of
//      specific fields when Performance is mtpfBalanced or mtpfSmall.
//      Fixed locate on date or time fields giving variant conversion error.
//      Problem reported by Tim Daborn (Tim_Daborn@Compuserve.com).
//      Updated Russian ressources and added Ukrainian ressources by
//      Vladimir (grumbler@ekonomik.com.ua)
//
//2.50e Fixed delete on master when attached to it.
// Beta Fixed delete on client table without versioning enabled
//      attached to a master with versioning enabled.
//      The bug fix makes sure the client is using same versioning
//      method as the master table.
//      Bugs reported by Davy Anest (davy-ane@ebp.fr)
//      Vladimir (grumbler@ekonomik.com.ua) suggested a bit different way of
//      copying field properties from during attaching to a master table.
//      Since I cannot completely grasp the implications of the changed scheme,
//      I have included it to leave it up to you to test it. The old scheme
//      is commented out in SetAttachedTo.
//      Alex Wijoyo (alex_wijoyo@telkom.net) suggested changing CreateTableAs.
//      Instead of using FieldDefs.Assign.... then a routine of our own is used.
//      This to avoid complications he had using TkbmMemTable in a DLL.
//      ProviderFlags are now copied in CopyFieldProperties. Bug reported by
//      Csehi Andras (acsehi@qsoft.hu).
//      Hungarian ressource file updated by Csehi Andras (acsehi@qsoft.hu).
//      InternalSave.... fixed when not specifying mtfSaveBlobs.
//      Fixed InternalLoadFrom..... A/V when stream size = 0.
//      Bugs reported by Ars�ne von Wyss (arsene@vonwyss.ch).
//      Changed InternalLoadFromStream to not call progress on each line,
//      but rather on each 100 lines.
//      Added MarkAllDirty in TkbmIndexes to make sure UpdateIndexes will
//      make a full update of all indexes regardless of previous state.
//      Solves bug when sequence Open table, Close table, LoadFrom.... didnt
//      update indexes correctly.
//      Added properties CSVTrueString and CSVFalseString for setting
//      stringrepresentation of true and false. Default value 'True' and 'False'.
//      Notice they are caxe sensitive.
//      Updated demo project to show OnProgress event.
//      Added new class TkbmSharedData for datasharing between memtables.
//      Modifed TkbmCustomMemtable to use this new class.
//      Added Standalone property which can be set to true for true standalone
//      memorytables that is tables that are not attaching to other table and other
//      tables dont attach to. The table is not threadsafe if Standalone=true.
//      It can gain a few percentage of speed.
//      Reintroduced Capacity property for prespecifying expected number of records.
//      Today i've tested inserting 1 million records of 1 string field with field
//      length 10 chars. Its able to insert 100.000 recs/sec.
//      Method used:
//        kbmMemTable1.Open;
//        kbmMemTable1.DisableControls;
//        kbmMemTable1.EnableIndexes:=false;
//        kbmMemTable1.Performance:=mtpfFast;
//        kbmMemTable1.Standalone:=true;
//        kbmMemTable1.Capacity:=1000000;
//        for i:=0 to 999999 do
//            kbmMemTable1.AppendRecord(['ABC']);
//        kbmMemTable1.EnableIndexes:=true;
//        kbmMemTable1.UpdateIndexes;
//        kbmMemTable1.EnableControls;
//      Added RecNo and UniqueRecID properties to TCustomDeltahandler to obtain
//      those informations from the current record during resolve.
//      Changed LoadFromDataset to avoid closing and opening the table
//      unless needed. Suggested by Stefano Monterisi (info@sesamoweb.it)
//      Setting RecordTag fixed. Problem reported by CARIOTOGLOU MIKE (Mike@singular.gr)
//      Several properties now must be set when table is inactive:
//        EnableVersioning, VersioningMode, AutoIncMin, Performance, Standalone,
//
//2.50f Fixed missing scroll event on SetRecNo. Problem reported by jcyr@jeancoutu.com.
// Beta Fixed A/V on setting or getting recno when table closed. Problem
//      reported by ycloutier@jeancoutu.com.
//      Removed active checks for Performance, EnableVersioning, VersioningMode,
//      AutoIncMin.
//      Fixed wrong default value for VersioningMode. Now its mtvm1SinceCheckPoint again.
//      Altered SetRecordTag to use RecordID instead of RecordNo.
//      Fixed A/V when versioning on records with blobs. Bug reported by
//      Davy Anest (davy-ane@ebp.fr)
//      Added Modified property to table to determine if the data in the table has been
//      modified. Set Modified:=false to clear the flag.
//      Modified tabledesigner to allow borrowing structure from datamodules too.
//      Submitted by Andrew Leiper (Andy@ietgroup.com)
//      Fixed bug closing a table where children are attached to. Now the children are
//      closed too. Bug reported by Davy Anest (davy-ane@ebp.fr).
//      Fixed bug opening a table which is attached to a closed table. Now the
//      'master' table will be opened too.
//      Changed the use of TCriticalSection to TRTLCriticalSection for non Level 5
//      compilers. Should make D3 compilation possible.
//      Changed SetEnabled of TkbmIndex to use a FEnabled field instead of ixNonMaintained.
//      Should make D3 compile. Reported by peter nouvakis (nouvakis@freemail.gr).
//      CreateTableAs fielddefs assignments changed for Level 3 compilers.
//      Reported by peter nouvakis (nouvakis@freemail.gr).
//
//2.50g Fixed two stupid bugs introduced in 2.50f:
// Beta  Indexes being disabled by default, and a blob destruction when no blob
//       existed. Sorry folks. Thats what happens when time for open source
//       development is in the late evening :)
//      Added default statements to properties. Suggested by CARIOTOGLOU MIKE (Mike@singular.gr)
//      Updated Ukrainian and Russian ressource files by Vladimir Piven (grumbler@ekonomik.com.ua)
//      Removed extra unneeded CopyFieldProperties line in SetAttachedTo.
//      Reported by Vladimir Piven (grumbler@ekonomik.com.ua)
//      All binary searching functions changed from recursive to non recursive.
//      Suggested by CARIOTOGLOU MIKE (Mike@singular.gr)
//      Fixed 'out of range' bug in SetFieldData and GetFieldData on calculated fields.
//
//2.50h Changed name of Modified property introduced in 2.50g Beta to IsDataModified to
// Beta avoid pretty serious conflict with TDataSet.Modified which only works on record
//      level.
//      Fixed setting DeletedCount to 0 in EmptyTable. Bugs reported
//      by CARIOTOGLOU MIKE (Mike@singular.gr).
//      Fixed bug not clearing the deletedlist after internalpack. Bug reported by
//      Edison Mera Men�ndez (edmera@yahoo.com).
//      Fixed bug setting masterlink=nil during save of data. Now a flag FMasterLinkUsed
//      will be set to false if mtfSaveIgnoreMasterDetail is specified in saveflags, and
//      reset to true after the save finished. Reported by GIANNAKOPOULOS KOSTAS
//      (kyan@singular.gr)
//      Added mtcpoFieldIndex for specifying copying 'Index' position of field
//      during CreateTableAs to make sure the order of the field columns are
//      the same as the source. Problem reported by IMB Tameio (vatt@internet.gr)
//      Changed bookmarks from storing RecordNo to storing a PkbmRecord pointer.
//      This will make bookmarks behave correct. Many thanks to several people
//      which came with suggestions. The used suggestion was from
//      CARIOTOGLOU MIKE (Mike@singular.gr).
//
//2.50i Major changes in shareddatarecord system. Rewritten to use TkbmCommon class. 4. Jan. 2001
// Beta Rewritten parts of VarLength and blob handling to fix several bugs
//      and leaks.
//      Changed so each attaced table has its own bookmark in the record.
//      Thus total recordsize is dependent on the number of tables attached
//      to it.
//      Implemented lots of fixes and memory optimizations.
//      Fixed and updated designer for loading of data from another TDataset
//      + several other bugs which could cause D5 to hang without posibility
//      to exit.
//      Implemented fix in GetLine by Primoz Gabrijelcic (gabr@17slon.com)
//      Fixed missing quoting of boolean field on save. Reported by Juergen (jschroth@gmx.de)
//      Added saveflag mtfSaveFieldKind. If specified together with mtfSaveDef,
//      the field kind will be restored when data is loaded again.
//      Thus fileformat is upgraded to 250, but should be backwards read
//      compatible.
//      Fixed autoreposition when no keys changed. Bug reported by Davy Anest (davy-ane@ebp.fr)
//      Renamed GetDeletedRecordsCount function to a property DeletedRecordsCount.
//      Journaling removed! Let me hear if that is a problem.
//      Implemented different BinarySearch algorithm long time ago suggested by
//      CARIOTOGLOU MIKE (Mike@singular.gr).
//      Fixed comparebookmarks to also compare on recordid.
//      Fixed bug trying to copy data to autoinc field in destination table using
//      SaveToDataset. Reported by Bohuslav �vancara (boh.svancara@quick.cz).
//      Fixed test for Field.Readonly in SetFieldData. Should use take dsSetKey
//      dataset state into account. Reported by Bohuslav �vancara (boh.svancara@quick.cz)
//      ftWideString and ftGUID support during LoadFromDataset and CreateTableAs
//      as a normal ftString.
//      Fixed so autoinc is not populated during InternalLoadFromStream if the
//      field is in the data to load.
//      Changed so InternalLoadFromBinaryStream can load v. 1.xx files.
//      Solution suggested by Paul Moorcroft (pmoor@netspace.net.au)
//      Fixed SetRecNo to use GetRecNo instead of relying on FRecNo.
//      Fix suggested by Stefan Knecht (StefanKnecht@gmx.de)
//      Fixed bookmark error string in german ressource file by Stefan Knecht.
//      Added _REAL_ localization support through LocaleID, LanguageID, SubLanguageID
//      and SortID. In D5 LocaleID also presents a human readable list of
//      available locales. Setting LocaleID will autoupdate LanguageID, SubLanguageID
//      and SortID, and setting any of those will update LocaleID.
//      Made sure it could compile in D3! :)
//      Time to release and get on with my real work!                      7. Jan. 2001
//
//2.50j Fixed TkbmCommon._InternalEmpty wrong call to Indexes.Rebuild.
// Beta Fixed EmptyTable not clearing buffers. Bugs reported by
//      Michael Gillen (Michael@gillenconsultinggroup.com)
//      Added OnSetupFieldProperties event where field properties can
//      be changed during load of structures.
//      Added ClearBuffers to Commit, Rollback, CheckPoint, PackTable to
//      make sure the internal TDataSet buffers are refreshed.
//
//2.50k Added AttachMaxCount which can be set to indicate how many tables   18. Jan. 2001
// Beta should be allowed to be attached to the base table without record
//      structure must change. Note that this takes up approx 8 bytes/attachment
//      /record. There is allways minimum one attachment (the base table itself).
//      As long there are free entries, they will be used. When no more free
//      entries are available and some table is open, an exception will be raised.
//      Changes in InternalOpen, CheckActive,CheckInActive,InternalClose,SetAttachedTo.
//      Persistent files layout must since v. 2.50i be defined in the table at
//      designtime to avoid exceptions. This will be corrected in v.3.00
//      Altered InternalEmptyTable to preserve state. Suggestion by (Alex@ig.co.uk).
//      Fixed 1.st record varlengths shown incorrect when Performance<>mtpfFast.
//      Bug reported by Szak�ly Bal�zs (szakalyb@freemail.hu).
//      Fixed setting indexname using different case than created index.
//      Bug reported by Joseph Gordon (pdsphx@parishdatainc.com)
//      Changed .Value to .AsString in CopyRecords and UpdateRecords to fix
//      TLargeIntField not supporting variants.
//
//2.50l Fixed 'Invalid record' error in GetData when varlength field is null.
// Beta Added procedure AssignRecord(Source,Destination:TDataSet);
//      to move the reoord of the active source record to the active dest record.
//      Suggested by Christian Weber (christian.weber@nextra.at)
//      Added DetailFields for master/detail relations. Use DetailFields instead
//      of the TTable standard IndexFieldNames for specifying detail fields in
//      a master/deta�l relation.
//      Fixed design and runtime bugs with master/detail.
//      Fixed Search routine to correctly track record.
//      Bug reported by Bohuslav �vancara (boh.svancara@quick.cz)
//      Fixed SetRecNo delta count and removed resync. Bug reported by paulp@eriksonpro.com.
//      Fixed GetRecNo return based on 0 should be 1. Bug reported by ut@tario.net
//
//2.50m Fixed TDateTime filter bug as suggested by Yuri Tolsky (ut@tario.net)
// Beta Fixed 'List index out of bounds (-1)' in BinarySearch by Yuri Tolsky (ut@tario.net).
//      Fixed bug in InternalSaveToStream/InternalSaveToBinaryStream where field was
//      saved even if it was not matching the saveflags (mtfSaveData,mtfSaveCalculated,mtfSaveLookup).
//      Bug reported by Les Pawelczyk (lpawelczyk@pixelpointpos.com)
//      Fixed bug tracking record in BinarySearch. Bug reported by Yuri Tolsky (ut@tario.net).
//
//2.50m2 Fixed Locate on first record in index. Bug reported by Yuri Tolsky (ut@tario.net).
// Beta
//
//2.50m3 Fixed Insert of records using index. Bug reported by scs.inf@mail.telepac.pt.
// Beta  Fixed so delete of record will update indexes regardless of EnableIndexes
//       to avoid pointer prob. on f.ex. grid refresh. Problem reported by
//       paulp@eriksonpro.com.
//
//2.50m4 Fixed GotoKey/FindKey/FindNearest not to return true if record not found.
// Beta  Bug reported by Ove Bjerregaard (dev_dude2001@yahoo.com).
//
//2.50n  Added Exists function to evaluate if the persistant file allready exists.
// Beta  Suggested by Tom Deprez (tom.deprez@village.uunet.be).
//       Added support for wildcard comparisons in filters by Yuri Tolsky (ut@tario.net)
//       Added support for BCD in filters for D5/BCB5 only by CARIOTOGLOU MIKE (Mike@singular.gr)
//       Removed BCDtoCurr and CurrToBCD from TkbmCustomMemTable since they were incorrect and
//       not used.
//
//2.50o  Fixed varlength bug in comparerecords. Bug reported by Jerzy Labocha (jurekl@ramzes.szczecin.pl)
//  Beta Fixed transaction handling. Bug reported by Radovan Antloga (radovan.antloga@siol.net)
//       Changed some Resync's to Refresh to better keep current record position.
//
//2.51   Fixed SetBlockReadSize which should only do next in D4 for fixing
// Beta  duplicate record bug in Midas for Delphi 4.00-4.03.
//       Added mtfSaveNoHeader to saveflags. If specified will not save field name header
//       line. Remember that LoadFromFile/Stream will _allways_ skip the first record in the
//       file/stream regardless of this flag. Thus mainly use mtfSaveNoHeader for appending
//       to an existing file or for other external use.
//       Added posibility to set CSVQuote to #0 to not use quotes for both save and load.
//       Be carefull not to have , in your field data and empty fields will allways
//       be interpreted as being null.
//       Now creating file if its not existing using mtfSaveAppend. Suggested by
//       Wilfried Mestdagh (wilfried_sonal@compuserve.com)
//       Fixed D4 compatibility to do with ftGUID.
//       Added support for saving/loading defaultexpression when saving field defs.
//       Fieldkind is now allways saved in the file if definitions are saved.
//       If mtfSaveFieldKind is not specified, it is saved as 'data' as fieldkind.
//       Binary file version is now 251, CSV file version is now 251.
//
//2.51b  Fixed allowing TDateTime and strings for PopulateField of date/time/datetime fields.
// Beta  Bug reported by Radovan Antloga (radovan.antloga@siol.net).
//       Fixed bug on persistent save when backup file exists by Naji Mouawad (naji@home.com)
//       Fixed GetRecNo when table is emptied.
//       Fixed missing index update when record is deleted and versioning is enabled.
//       Added filtered indexes. You can decide using a filter which records should be
//       part of an index when inserting and editing records. Check AddFilteredIndex function.
//       The filter doesnt have to be on the field(s) which are indexed.
//       Added OnFilterIndex event functioning like the OnFilterRecord except for indexes.
//       Fixed bug attaching on open table even if AttachMaxCount is set. Bug reported by
//       Andrew Leiper (Andy@ietgroup.com).
//       Refixed D4 ftGUID compile bug which should be fixed in 2.51 Beta.
//       Moved DisableControls in front of a try block as suggested by IMB (vatt@internet.gr)
//       Fixed missing reset of result in StringToBase64 when len=0 as reported by
//       delphi5 (delphi5@freemail.hu)
//
//2.52a  Fixed allowing also Double, Integer, Single to be used for argument for populatefield of
// Beta  date/time/datetime fields. Problem reported by Radovan Antloga (radovan.antloga@siol.net).
//       Changed InternalLoadFromStream to handle autoskipping fields which is not
//       present in either source file or table field definition.
//       Added posibility to specify index/sort/key options per field by using an enhanced
//       FieldNames syntax. The normal syntax is: fldname1;fldname2;fldname3...
//       The enhanced syntax allows adding a colon and some options to each of the fieldnames.
//       Eg: fldname1:C;fldname2:DC;fldname3
//       Which means fld specified with fldname1 should be case insensitive,
//       field specified with fldname2 should be descending and case insensitive,
//       and fldname3 should be ascending and case sensitive.
//       The following options are recognized:
//          C for Case insensitive,
//          D for Descending,
//          P for Partial,
//          N for ignore Nulls,
//          L for ignore Locale.
//       The changes was inspired by a descfields contribution from
//       Michael Bonner (michaelbonner@earthlink.net).
//       If SortOptions etc are specified, they overrule field specific settings.
//       Added backwards compability to IndexFieldNames in Master/Detail.
//       If DetailFields are not specified, but IndexFieldNames are, IndexFieldNames will be
//       used.
//       Fixed a few more compile bugs for pre LEVEL5 compilers.
//
//2.52b  Fixed bug using LoadFromStream to load a stream containing fewer fields than
// Beta  in memory table.
//
//2.52c  Removed overriding statefield in EmptyTable. Bug reported by Alex.Gromyko@ig.co.uk.
// Beta  Fixed AppendRecord using varlength fields. Was not copying varlengths
//       in InternalCopyRecord. Bug reported by Darren Wade (waded@dameaurora.f2s.com)
//       Added missing DisableControls in EmptyTable. Bug reported by
//       IMB T (vatt@internet.gr)
//
//2.52d  Added check for table open in SaveToxxxx. Bug reported
// Beta  by Chris G. Royle (chris.royle@valmet.com)
//       Moved Precision setting of TBCDFields from CopyFieldProperties to
//       CreateFieldAs. Bug reported by Harry Holzhauser (harryh@pobox.com).
//       Fixed setting active record during indexfilter. Bug reported
//       by Timo Salmi (tjs@iki.fi).
//       Changed EmptyTable to correctly update attached tables.
//       Suggestion by IMB T (vatt@internet.gr).
//       Fixed A/V bug when rearranging order of fields (f.ex. in a grid) and
//       stringfield is present. Bug reported by Anders Obermueller (obermueller@lop.de)
//       Fixed bug F�ltering according to expression even if Filtered:=false.
//       Cleaned up use of Refresh.
//
//2.52e  Refixed Index filtering bug.
// Beta
//
//2.52f  Enhanced CopyRecords to fix both LargeInt and Date/Time fields.
// Beta  If source and dest is same type, but not largeint, value will be used,
//       else AsString.
//       Bug reported by Steven Kamradt (steven@resource-dynamics.com).
//       Fixed bug in InternalInitFieldDefs where also predefined non data fields
//       was used as a template for a fielddef.
//       Removed wrong Validate call in GetFieldData.
//       Fixed setting field modified flag for blobfields whn operation is ReadWrite.
//       Now allowing creating an index without name. Not recommended though!
//       Bugs rep. by Mogens B. Nielsen (mobak@teliamail.dk)
//       Fixed missing calculate of fields during save/binarysave.
//       Bug rep. by Jerzy Labocha (jurekl@ramzes.szczecin.pl).
//       Fixed Standalone setting bug.
//       Bug rep. by Jerzy Labocha (jurekl@ramzes.szczecin.pl) and others.
//       Filter functions enhanced. Contribution by Markus Landwehr
//       (leisys.entwicklung@leisys.de). Now following operators and functions
//       are available in a filter: =,<>,>,>=,<,<=,+,-,*,/,(,),
//       ISNULL,ISNOTNULL,NOT,IN,LIKE,YEAR,MONTH,DAY,HOUR,MINUTE,SECOND,GETDATE,
//       DATE,TIME.
//
// 2.52g Removed leftover validate in GetFieldData. Bug reported by         4. Apr. 2001
// Beta  Mogens B. Nielsen - Danish Software Development A/S (mobak@teliamail.dk)
//       Fixed bug table sending A/V after attaching to another table and exception
//       raised. Bug reported by Michael Bonner (michael.bonner@ci.fresno.ca.us)
//       Fixed Index.Rebuild not validating recordnumber bug reported by
//       Timo Salmi (tjs@iki.fi).
//       Added AttachCount readonly property which returns the current number
//       of attached tables.
//       Fixed bug in CopyRecord as reported by IMB T (vatt@internet.gr).
//       Added support for Boolean fields in PopulateField by
//       Jeffrey Jones - Focus Land & Legal Technologies (jonesjeffrey@home.com).
//       Updated Dutch ressource file by avegaart@mccomm.nl.
//       Fixed SetRange to allow specifying null or less than indexfieldnames.count
//       entries. Bug reported by Ove Bjerregaard (dev_dude2001@yahoo.com).
//
// 2.52h Fixed FindNearest. Bug reported by florian@radiotel.ro (florian@radiotel.ro).
// Beta
//
// 2.52i Fixed record inserted after cur record instead of before using roworder index.
//       Bug reported by N.K. MacEwan B.E. E&E (neven@mwk.co.nz)
//       Fixed locate bug when fieldmodifiers given and on current index.
//       Bug reported by florian@radiotel.ro and others.
//
// 2.53  Fixed compare multiple string fields. Bug reported by Everix Peter (peter.everix@wkb.be)
//       Fixed compilation bug when BINARY_FILE_1XX_COMPATIBILITY was defined.
//       Fixed AutoInc field not correctly handled in some situations.
//       Problem reported by Martin Kreidenweis (80171@gmx.de)
//       Added protected method SetLoadedCompletely(AValue:boolean).
//       Improved threadsafeness. Remember that the VCL and dataaware
//       controls are _not_ threadsafe. To remedy this, in a thread
//       before any updates or access to the table do
//       mt.Lock;
//       try
//        ....
//       finally
//         mt.Unlock;
//       end;
//       This also makes dataaware controls behave relatively nicely.
//       Fixed loading CSV data where last field is only 1 char and not quoted.
//       Bug reported by Mark Voevodin (marner@bigpond.net.au)
//       Added support for FindFirst,FindNext,FindPrior,FindLast using filter
//       expreesion or onFilterrecord as search criteria, even if Filtered:=false.
//       Enhancement (and making kbmMemTable more TTable compatible) suggested by
//       Mikael Willberg (mig@vip.fi).
//       Added support for dest. fields of type ftWideString in
//       SaveToDataset and UpdateToDataset.
//       Returning nil on TkbmIndexes.Get instead of raising an exception.
//       Bug reported by Chris Michael (nojunkmail@computeralchemist.com)
//       Altered CopyRecords not to call RecordCount unless an OnProgress
//       eventhandler is assigned. Suggested by Dan (programinator@yahoo.com)
//       Fixed A/V when EmptyTable called during table state dsEdit/dsInsert.
//       Bug reported by chetta19@yahoo.com.
//       Fixed so EmptyTable resets index to row order index.
//       Added support for Delphi 6.
//
// 2.53a Re-removed wrong RecordCount reference :)
//       Fixed pretty hard to find indexing bug reported
//       by Sergei Safar (hissa59@ig.com.br)
//
// 2.53b Fixed wrong insertion order in the row order index.
//       Bug reported by Primoz Gabrijelcic (gabr@17slon.com)
//       Fixed Range bug in BinarySearch.
//       Fixed setting filter not refreshing correctly. Bug reported by karsten.pester@locom.de.
//       Added flags mtufAppend, mtufEdit to UpdateToDataset.
//       Level5 compilers also keep backwards compatible old version of UpdateToDataset.
//       Contribution by Thomas Everth (everth@wave.co.nz)
//       Added TkbmIndexes.GetIndex(Ordinal:integer):TkbmIndex for getting an index
//       by ordinal number.
//       Fixed switching to a filtered index when current record is not accepted by index filter.
//       Bug reported by Maurizio Lotauro (Lotauro.Maurizio@dnet.it).
//       Added DesignActivation property (default true) which decides if
//       the table should be automatically activated at runtime if it was active
//       during save in designtime. Suggestion from Maurizio Lotauro (Lotauro.Maurizio@dnet.it).
//       Fixed so SaveToxxxx and UpdateToxxxx makes calls CheckBrowseMode to
//       ensure that the table is in browse mode, and not any edit/insert modes.
//       Bug reported by Maurizio Lotauro (Lotauro.Maurizio@dnet.it).
//
// 3.00a Moved FieldTypeNames and FieldKindNames to interface section for
// alpha compability with kbmMW.                                         22. July 2001
//       Removed wrong setting of FRecalcOnIndex in BuildFieldList.
//       Made BuildFieldList, FindFieldInList, IsFieldListsEqual and
//       SetFieldListOptions public.
//       Fixed A/V bug setting Deltahandler to nil.
//       Rearranged I/O scheme. Thus SaveToBinaryxxxx, LoadFromBinaryxxxx and
//       SaveToxxxx and LoadFromxxxx along with all the CSV save flags are
//       not available anymore. Instead two new components TkbmBinaryStreamFormat,
//       and TkbmCSVStreamFormat has been introduced. New formats for save and
//       load can be build by inheriting from TkbmCustomStreamFormat or
//       TkbmStreamFormat.
//       OnCompressBlobStream and OnDecompressBlobStream has an extra ADataset parameter.
//       This will require you to make a small change in your code for your event handler.
//       (De)Compression of load/save operations has now been moved to the TkbmCustomStreamFormat
//       components. Thus code for these events need to be moved.
//       Improved bookmarkvalid check by adding TkbmUserBookmark.
//
// 3.00b Added OnBeforeLoad, OnAfterLoad, OnBeforeSave and OnAfterSave to TkbmCustomStreamFormat.
// alpha Fixed GetRecord(grCurrent) when filter not matching.
//       Fixed missing Refresh in SwitchToIndex when FRecNo=-1;
//       Bugs reported by Kuznetsov A. V. (kuaw26@mail.ru)
//       Added protected SetTableState(AValue:TkbmState) by request of
//       Kuznetsov A. V. (kuaw26@mail.ru)
//       Removed DesignActivation from D3 since D3 doesnt have SetActive.
//       Fixed Lookup field type bug reported by Giovanni Premuda (gpremuda@softwerk.it).
//       Fixed setting IsDataModified when versioning is enabled and record deleted.
//       Bug reported by Radek Zhasil (radek.zhasil@vitkovice.cz).
//       Altered CopyRecords to copy autoinc value from source if destination table is empty.
//       If not, a new unique value will be generated.
//       Fixed FindKey/GotoKey returning True on second run even if key not found.
//       Bug reported by Sergei Safar (hissa59@ig.com.br).
//       Reordered property entries of TkbmCustomMemTable to make sure
//       AttachedTo is set before all other properties. Note this require that
//       the form is saved again to update the dfm file with the changed order.
//       Bug reported by Maurizio Lotauro (Lotauro.Maurizio@dnet.it).
//       Split the kbmMemStreamFormat.pas file into kbmMemCSVStreamFormat.pas and
//       kbmMemBinaryStreamFormat.pas since its the most logical thing to do.
//       All changes specific to those formats will be written in a history
//       in the start of each of the files.
//       Updated Slovakian ressource file by Roman Olexa (systech@ba.telecom.sk)
//
// 3.00c Fixed SetRange on multiple fields. In previous versions, the combined
// alpha set of fields was compared instead of field by field as Borland describes.
//       Bug reported by Dave (rave154@yahoo.co.uk).
//
// 3.00d Added Assign method to TkbmCustomStreamFormat.
// alpha Fixed Comparebookmarks to return -1,0 and 1 specifically.
//       Fixed not raising keyfields has changed exception when editing keyvalue
//       on a filtered index on an attached table. Bug reported by Timo Salmi (tjs@iki.fi).
//       Fixed AV when freeing base memtable to which others are attached.
//
// 3.00e Fixed _InternalCompareRecords when comparing two null fields.
// alpha Bug reported by Radovan Antloga (radovan.antloga@siol.net).
//
// 3.00f Added protected CheckpointRecord to TkbmCustomMemTable.
//       Added missing published OnCompress and OnDecompress properties to
//       TkbmStreamFormat.
//       Added public Stream property to TkbmStreamFormat.
//       Fixed bug reported by Andreas Oberm�ller <obermueller@lop.de> in D6
//       when requiredfields was not checked.
//       Fixed copying null fields in CopyRecords, UpdateRecords and AssignRecord.
//
// Entering BETA state!
// 3.00f1 Fixed A/V when dataset to which deltahandler connected is removed.
//       Added support for fkInternalCalc.
//
// 3.00f2 Added missing AllDataFormat property.
//       Virtualized LoadFromStreamViaFormat and SaveToStreamViaFormat.
//       Fixed bug in InternalCompareFields as reported by Radovan Antloga
//       (radovan.antloga@siol.net).
//       Added TestFilter method for applying a filter to the current
//       record to see if its matching the filter. Contributed by vatt@internet.gr.
//       Added sfSaveInsert flag to TkbmCustomStreamFormat which will save to a
//       stream at the current position. Other values are sfSaveAppend which will
//       append to the stream and none which will overwrite contents of stream.
//       sfAppend overrules sfInsert.
//       Added check for number of field defs in several places.
//       Updated some language ressource files.
//       Fixed designer to save in binary when the binary checkbox was checked.
//       Bug reported by Francois Haasbroek (fransh@argo.net.au).
//       Fixed borrowing from TDataset in designer in Delphi 6. Solution
//       provided by Jorge Ducano (jorgeduc@portoweb.com.br)
//       Added sfSaveUsingIndex to TkbmCustomBinaryFormat. Its default true to
//       keep backwards compability. Set it to false if to save according to
//       the internal record list which also maintains deleted records.
//       v. 3.00 now again supports Delphi 3.
//
// 3.00f3 Fixed floating point bug introduced in 3.00f2 in binary stream format.
//       Bug reported by Fred Schetterer (yahoogroups@shaw.ca).
//
// 3.00f4 Fixed MasterFields designer for inherited components.
//       Virtualized MasterChanged, MasterDisabled, CopyRecords, Progress,
//       Lock and Unlock.
//
// 3.00f5 Fixed deltahandler Value and OrigValue returning empty string instead of Null
//        when field is null.
//
// 3.00f6 Fixed massive leak in TkbmBinaryStreamFormat resulting from
//        missing to indicate records were part of table.
//        Changed so LoadFromDataset only issues First if source table was not on
//        first record. Will satisfy forward only sources.
//        Suggestion by Marco Dissel (mdissel@home.nl).
//        Added compiler directive for enabling short circuit evaluation.
//        Suggested by Bill Lee (mrbill@qualcomm.com)
//        Fixed Locate (and all other searching methods) on descending index.
//        Bug reported by Walter Yu (walter@163.net).
//        Fixed raising exception if no indexfieldnames given for FindKey.
//        Suggested by Sergei Safar (sergei@gold.com.br).
//        Fixed AutoReposition Index out of range when delete, close table, open table.
//        Bug reported by Federico Corso (federico.corso@eudata.it)
//
// 3.00f7 Fixed bug not copying autoinc value in CopyRec when destination table empty.
//        Was wrongly testing for source table empty.
//        Fixed bug negating a negate when comparing descending field indexes.
//        Fixed problem comparing longint and int64 fields in comparefields.
//        Fixed sorting bugs introduced in 3.00f6.
//        Fixed searching using FindKey/FindNearest on descending indexes.
//        Fixed CompareBookmark function to better test for invalid bookmarks.
//        Fixed Persistent save during destruction which could lead to A/V.
//
// 3.00f8 Fixed loading CSV files containing blobfields.
//
// 3.00f9 Added OnFormatLoadField and OnFormatSaveField event for reformatting of
//        data before they are actually loaded or saved.
//        Added sfQuoteOnlyStrings (CSV) flag for selecting to only quote string/binary fields during save.
//        Published sfNoHeader and completed support for it (CSV). It controls if a header should be saved or loaded.
//        Added raising an exception if Save... is called when table is closed.
//        Changed the result of OldValue for a field to return the original unchanged value
//        if versioning is enabled. This is to make kbmMemTable be more compatible with TClientDataset.
//
// 3.00g  Beta Fixed Commit/Rollback as suggested by (peter.bossier@sintandriestielt.be)
//        Made small changes for better support of fetch on demand in kbmMW.
//        Improved filtering to check for variant empty/null.
//        Added support for BCB6.
//        Added support for Kylix1. Please notice that the memtable designer although
//        ported for Linux, is not available simply because I cannot find a
//        decent way to invoke the default field editor programatically.
//        Thus all custom component editors have been disabled for Kylix 1.
//        RecordTag use while filtering bug fixed. Bug reported by Aart Molenaar (almo@xs4all.nl)
//        Fixed comparing very large values in CompareField which could raise OutOfRange error.
//
// 3.00 FINAL                                                             14. June 2002
//        Fixed minor problem not resetting internal TDataset flags correctly
//        after a binary load.
//        Rolled the rollback and commit change in 3.00g Beta back due to serious
//        problems. Sorry about that. Bug reported by hans@hoogstraat.ca
//        Added support for indexing Lookup fields. Suggested by hans@hoogstraat.ca.
//        Fixed C++ Builder 6 project which mistakenly referred to kbmMW file.
//        Added BufferSize property to binary stream format.
//        Suggested by Ken Schafer (prez@write-brain.com)
//        Fixed some Kylix compability situations by (Hans-Dieter Karl) hdk@hdkarl.com
//        Removed TkbmTreadDataset from Kylix distribution.
//        Added ClearModified method to TkbmMemTable to clear out modification flags
//        of both fields and table. Suggested by hans@hoogstraat.ca
//        Changed so IsDataModified flag is not set if Edit/Post do not change anything.
//        Suggested by hans@hoogstraat.ca
//
// 3.01   30. June. 2002
//        Changed TkbmIndex constructor to accept TkbmMemTableCompareOptions instead of
//        TIndexOptions.
//        Added global public functions:
//        IndexOptions2CompareOptions and CompareOptions2IndexOptions for
//        easy conversion between the two sets.
//        This allows for Sort/SortOn/SortDefault to utilize all special memtable
//        compare options. Further it enables manually created indexes via
//        TkbmIndex to take advantage of those features too.
//        Problem indicated by mariusz@nizinski.net.
//        Added new property AutoUpdateFieldVariables which is false by default.
//        Setting it to true automatically updates/adds field variables to the
//        owner of the memtable (f.ex. a form). Contributed by Ken Schafer (prez@write-brain.com)
//        Added support for ftFmtBCD.
//        Fixed InternalOpen problem which recreated fields/fielddefs for attached tables.
//        This resulted in severe problems when field order is different between base table
//        and attached table. Bug reported by michael.bonner@ci.fresno.ca.us.
//        Added support for ftTimestamp for LEVEL6 compilers (D6/BCB6).
//
// 3.02   15. July 2002
//        Internal version reserved for Delphi 7 and Kylix 3.
//        Fixed compilation problems in D4 and Kylix by adding missing IFDEF's.
//        Problem reported by several.
//        Fixed not equal filter bug reported by several.
//
// 3.03   7. August 2002
//        Kylix 3 and Delphi 7 support officially added.
//        Kylix 2 project files added.
//        Added several error classes:
//          EMemTableFatalError -> EMemTableInvalidRecord
//          EMemTableIndexError -> EMemTableDupKey
//          EMemTableFilterError
//          EMemTableLocaleError -> EMemTableInvalidLocale
//        Updated Italian ressource file by Alberto Menghini (alberto@asoft.it).
//        Updated Czech ressource file.
//        Updated Romanian ressource file by Sorin Pohontu (spohontu@assist.ro).
//        Made SavePersistent and LoadPersistent public.
//        Added public property PersistentSaved which indicates if persistent file
//        was saved. If true, SavePersistent will not be called again.
//        Added LookupByIndex by Prokopec M. (prokopec@algo-hk.cz)
//        Fixed 'List index out of range' while defining fielddefs with attribute hidden.
//        Bug reported by Adi Miller (dontspam@il.quest.com-adi)
//        Fixed so its ok to modify a field during OnCalcFields without putting
//        the dataset in edit mode.
//        Fixed problem with array and ADT fields. Bug reported by (huqd@mail.csoft.com.cn)
//
// 3.04   Fixed locking problem with resolver on table with attached tables and datacontrols
//        in threaded environment.
//        Modified InsertRecord, ModifyRecord, DeleteRecord, UnmodifiedRecord to
//        allow for Retry and State variable arguments.
//
// 3.05   28. Aug. 2002
//        Fixed autoinc population when using attached tables.
//
// 3.06   26. Sep. 2002
//        Added OnGetValue event to TkbmCustomResolver which is called when
//        the resolver requests the new value for a field.
//        Fixed endless loop in TkbmIndexes.DeleteIndex. Reported by
//        Markus D�tting (duetting@cosymed.de)
//        Removed ClearRange in SwitchToIndex to support keeping range while
//        switching index.
//        Made CheckPointRecord public.
//        Added support for ftOraBlob and ftOraClob field types for level 5+ compilers.
//
// 3.07   8. Nov. 2002
//        Fixed case bug confusing BCB. Declared RollBack implemented Rollback.
//        This lead to A/V's of adjacent functions in BCB.
//
// 3.08   11. Nov. 2002
//        Fixed compile bug in kbmMemTableReg.pas for LEVEL4 compilers.
//        Fixed small inconsistency in SequentialSearchRecord reported
//        by Markus D�tting (duetting@cosymed.de)
//        Fixed bug where OnGetValue was called in GetOrigValues instead
//        of GetValuesByName. Problem reported by WangWH (wangwh66@yahoo.com).
//        Fixed so setting filtered to same value as it already has is ignored.
//
// 3.09   15. Maj. 2003
//        Fixed missing AfterScroll event in GotoKey/FindKey/FindNearest.
//        Bug reported by Bill Miller (wcmiller@marimyc.com)
//        Fixed occational A/V on rollback of inserted values.
//        Bug reported by Gert Kello (gert@gaiasoft.ee)
//        Added Swedish resource file by Henrick Hellstr�m (henrick@streamsec.se)
//        Optimized binary search DoRespectFilter and fixed bug in some cases
//        resulting in finding a filtered records.
//        Bug reported by Artem Volk (artvolk@softhome.net)
//        Changed to disable filter when calling Reset.
//        Reported by Marco Kregar (mk_delphi@yahoo.com)
//        Fixed SetRange, SetKey etc. throwing exception when dataset readonly.
//        Bug reported by Ping Kam (pkam@quikcard.com)
//        Updated Spanish resource file by Francisco Armando Due�as Rodr�guez
//        (fduenas@flashmail.com)
//        Updated Italian resource file by Alberto Menghini (alberto@asoft.it).
//        Changed not to move DefaultExpression to LargeInt fields due to
//        Borland not fully having implemented largeint support in variants.
//        Changed OnCompareFields to include a AFld:TField value.
//        Notice that this breaks existing code which need to add that extra
//        argument to their code.
//        Fixed bug which could result in incorrect sorting of entries when
//        adding records.
//        Fixed bug in SaveToDataset which would cause non graceful exception
//        in case destination table could not be opened.
//        Fixed bug not loading last field in certain cases in CSV format.
//        Fix by Wilfried Mestdagh.
//        Published AllDataFormat.
//        Altered table designer to better list tables based on BDE alias.
//        Disabled platform warnings and hints.
//        Removed Application/Forms/Dialogs dependencies.
//        Extended AddFilteredIndex to accept an optional FilterFunc argument.
//        The filter function is of format:
//            TkbmOnFilterIndex = procedure(DataSet:TDataSet; Index:TkbmIndex; var Accept:boolean) of object;
//        Enhanced AddFiltered to allow for empty filterstring.
//        Fixed Search which would not correctly search on current descending index unless
//        complete correct field specifiers was given. Now use field specifiers for
//        current index if fields matching.
//        Added better error message for when trying to do LoadFromDataset with options for append and structure.
//
// 3.10   16. May 2003
//        Reimplemented InternalHandleException. Altered how it behaves under Kylix.
//        Fixed Notification which would give problems if the same streamformat was
//        attached to two StreamFormat properties at the same time.
//        Fixed persistency problems.
//
// 3.11   29. June 2003
//        Added MergeOptionsTo to TkbmFieldList.
//        Changed to TkbmIndexes.Search combine given field options with index field options.
//
// 3.12   30. June 2003
//        Made TkbmCustomDeltaHandler.Dataset writable.
//        Added mtufDontClear to TkbmMemTableUpdateFlags which if set, avoids clearing
//        out fields which are not to be set by UpdateRecords.
//        Changed to guarantee that AfterLoad is called in InternalLoadFromStreamViaFormat.
//        Bug reported by Vladimir Ulchenko (zlojvavan@bigfoot.com).
//        Fixed bug checking for number of fielddefs in CreateTable. Will now
//        for sure complain if more than KBM_MAX_FIELDS have been defined.
//        Fixed range error in CodedString2String. Bug reported
//        by Karl Thompson (karlt@pine-grove.com).
//        Changed several methods incl. CopyRecords from virtual to dynamic
//        for BCB only to solve BCB compile bugs.
//        Fixed counting when not accepting a record in CopyRecords and UpdateRecords.
//        Bug reported by Nick (nring@smf.com.au)
//        Fixed bug in SequentialSearchRecord with a missing pair of paranthesis.
//        Bug reported by winsano (llob@menta.net).
//        Modified TkbmIndexes.Search to always try to use matching index even if
//        its not current. Contributed by Markus D�tting (duetting@cosymed.de)
//        Added AutoAddIndex property (default false) which if set to true
//        will automatically add an index during a search if none are available.
//        Use cautiously since you could end up with lots of indexes that have to
//        be maintained. Contributed by Markus D�tting (duetting@cosymed.de)
//
// 3.13   Fixed 'List out of bounds' bug in TkbmFieldList.MergeOptionsTo
//        when the two lists was not of same length.
//
// 3.14   Fixed locate/search operations on fields which are not indexed.
//        Bug reported by Ole Willy Tuv (owtuv@online.no).
//
// 4.00   Added DoOnFilterRecord virtual method. Suggested by Neven MacEwan (neven@mwk.co.nz).
//        Fixed enforcing unique index checking in AppendRecord. Bug reported by
//        Thomas Wegner (thomas@wegner24.de)
//        Performance optimized kbmMemTable. Now much faster for many operations.
//        Fixed several indexing bugs.
//
// 4.01   Fixed compiler warning in ParseNode.
//        Fixed A/V in Commit. Reported by Willi (nonn@inwind.it)
//        Added new Pro features for benefit of valid kbmMW commercial license holders.
//        These features significantly speed up memorytable operations, specially
//        for large amounts of data.
//        Holders of valid kbmMW commercial developer licenses, please remember to
//        define HAVE_COMMERCIAL_KBMMW_LICENSE in your projects conditionals/define
//        to benefit from the Pro speed. Also remember to download the Pro features
//        seperately from C4D.
//        Updated Spanish ressource file by Francisco Armando Due�as Rodr�guez (fduenas@flashmail.com)
//        Added support for ftBCD fields in PopulateField by Arming (armintan@263.net)
//        Fixed ftGUID support.
//        Fixed locating on partial indexes, using index.
//
// 4.02   Fixed a serious string compare bug.
//        Fixed grid repositioning issue when deleting record. Reported by Rado Antloga (radovan.antloga@siol.net)
//        Added the darned BCB virtual/dynamic fix in all places in TkbmCustomMemTable.
//        Fixed USE_FAST_MOVE definition which were misspelled several places.
//
// 4.03   Fixed null comparison bug in TkbmCommon._InternalCompareRecords reported by
//          Emmanuel TRIBALLIER (emmanuel.triballier@ebp.com).
//        Added call to clearbuffers when setting filter or enablefilter to force
//        a complete refetch of all TDataset buffers.
//        Fixed installation in Level 4 compilers (ftGUID field type not supported).
//
// 4.04   Fixed cancel resets cursor to first row. Reported by Rado Antloga.
//        Removed ClearBuffers from SetRecNo. Reported by Rado Antloga.
//        Altered AddIndex and AddFilteredIndex to be functions returning the
//        added index.
//        Fixed enabling filtering before table opening. Reported by peter.andersen@dsd.as
//        Fixed CompareFields ftTime comparison.
//        Fixed nasty memory leaks in PrepareKeyRecord, LocateRecord and LookupByIndex.
//        Leak reported by Wilfied Mestdagh.
//        Fixed coNOT operator not correctly returning Null instead of boolean value
//        when arguments is null. Bug reported by Peter Andersen (peter.andersen@dsd.as)
//        Fixed bug when calling Sort or SortOn while in Edit mode. Problem reported by
//        Francesco Beccari (fbeccari@interplanet.it).
//        Fixed compilation problems in Kylix.
//        Fixed Commit and Rollback transaction handling.
//
// 4.05   Added support for sfLoadIndexDef in sfIndexDef in binary and csv streamformats.
//        Thus its possible to not load indexes.
//        Added new boolean property RangeIgnoreNullKeyValues which controls if
//        Null values are to be ignored or not in the key values for ranges.
//        Default true.
//        Fixed bug with reposition on deleted record. Fix by Wilfried Mestdagh.
//        Fixed bug when Filtered:=true and Filter<>'' at designtime. Then
//        opening table do not correctly set Filter. Reported by Rado Antloga.
//        Fixed bug clearing main filterexpression when a filtered index is added.
//        Added IgnoreErrors argument to CopyRecords. Will ignore errors in assigning
//        field values and posting the record and continue to operate.
//        Added mtcpoIgnoreErrors and mtcpoDontDisableIndexes to TkbmMemTableCopyTableOptions.
//        Updated LoadFromDataset to respect mtcpoIgnoreErrors and mtcpoDontDisableIndexes.
//        Added CopyOptions argument to SaveToDataset. Only mtcpoIgnoreErrors is currently supported.
//        Added true ftWideString support (Unicode) also for csv and binary streamformats (LEVEL6+ compilers only).
//        Pre LEVEL6 compilers will convert the widestring to a normal string using the AsString field method.
//        Added AddIndex2 and AddFilteredIndex2 (pre LEVEL5 compilers) and overloaded AddIndex/AddFilteredIndex
//        (LEVEL5+ compilers) which includes a TUpdateStatusSet argument.
//        This allows for the index to show or filter specific updatestatus settings incl. deleted.
//        Added Undo to revert to older record version.
//        Disabled warnings in ParseNode due to unremovable warning. By Wilfried Mestdagh.
//        Fixed _InternalCompareRecords to handle comparing null values correctly on descending indexes.
//        By Rado AntLoga.
//        Added TkbmMWIndex.CreateByIndexDef (Pre LEVEL5 compilers) and TkbmMWIndex.Create overloaded
//        (LEVEL5+ compilers) which allow for specifying TIndexDef. By Rado Antloga.
//        Changed Refresh to Resync in SwitchToIndex and UpdateIndexes. By Rado Antloga.
//        Changed so fields are default visible when attaching to another table. By Julian Mesa.
//        Added conditional CreateFields in InternalInitFieldDefs
//
// 4.06   Fixed not to default HAVE_COMMERCIAL_KBMMW_LICENSE definition.
//        Fixed problem with indexes not setup to include inserted, modified and unmodified records by default
//        using one of the TkbmIndex constructors.
//        Updated demo to fix compilation problem regarding AddFilteredIndex.
//        Fixed the dreaded varlength getting null when calculated fields before varlength fields.
//
// 4.07   Fixed version string :|
//        Rewrote WideString support as the other way broke lots of other fieldtypes... Sorry folks!
//        Now done the 'right' way via the DataConvert method which of some strange reason
//        do not natively support WideString. Fortunately its possible to override it and fix it.
//        Added functions for setting fielddata and status for any version of a record. The old value is returned.
//        function SetVersionFieldData(Field:TField; AVersion:integer; AValue:variant):variant;
//        function SetVersionStatus(AVersion:integer; AUpdateStatus:TUpdateStatus):TUpdateStatus;
//        Fixed D5 problems regarding overloaded AddFilteredIndex.
//
// 4.08   Added support for mtcpoStringAsWideString copy flag which if set means that all
//        string and memo fields will be created as widestring instead of string.
//        Added support for mtcpoWideStringUTF8 which means that all loadfromdataset/
//        savetodataset operations automaticaly includes UTF8 conversion.
//        Fixed bug with regards to loading widestring data in CSV streamformat.
//        Added sfDataTypeHeader to binary stream format which will allow storing
//        datatypes in the header. The information can be used to skip fields later on.
//        Notice that if this is used, it will break backward compatibility with older
//        binary files and with older versions of kbmMemTable.
//        Fixed repositioning problem after UpdateIndexes was run.
//        Fixed Kylix 3 compatibility.
//=============================================================================

//=============================================================================
// If you have a valid commercial kbmMW developer license, uncomment the next
// line to gain significant amounts of speed.
//{$define HAVE_COMMERCIAL_KBMMW_LICENSE}
//=============================================================================

//=============================================================================
// Remove the remark on the next line if all records should be checked before use.
//{$define DO_CHECKRECORD}
//=============================================================================

//=============================================================================
// Comment the next line to use the standard Quicksort algorithm.
{$define USE_FAST_QUICKSORT}
//=============================================================================

//=============================================================================
// Uncomment the next line to use less optimized code.
{$define USE_SAFE_CODE}
//=============================================================================

{$IFDEF HAVE_COMMERCIAL_KBMMW_LICENSE}
 {$IFNDEF LINUX}
  {$DEFINE USE_FAST_STRINGCOMPARE}
  {$IFDEF LEVEL6}
   {$DEFINE USE_FAST_MOVE}
  {$ENDIF}
  {$DEFINE USE_FAST_LIST}
 {$ENDIF}
{$ENDIF}

{$IFDEF BCB}
{$ObjExportAll On}
{$ASSERTIONS ON}
{$ENDIF}

uses
  SysUtils,
  Classes,
  DB,
  DBCommon
{$IFDEF LINUX}
  ,Types
  ,Libc
{$ELSE}
  ,Windows
{$ENDIF}
{$IFDEF LEVEL5}
  ,SyncObjs
  ,Masks
{$ENDIF}
{$IFDEF LEVEL6}
  ,variants
  ,fmtbcd
  ,SqlTimSt
{$ENDIF}
// If you get compile error here then its because HAVE_COMMERCIAL_KBMMW_LICENSE
// is defined further up without you actually having installed the Pro additions
// of kbmMemTable. The Pro edition is only available with kbmMW commercial edition.
// To fix, comment the {$DEFINE HAVE_COMMERCIAL_KBMMW_LICENSE} further up, or
// install kbmMemTable Pro addtions.
{$IFDEF USE_FAST_STRINGCOMPARE}
  ,kbmString
{$ENDIF}
{$IFDEF USE_FAST_LIST}
  ,kbmList
{$ENDIF}
{$IFDEF DOTNET}
  ,System.Runtime.InteropServices
{$ENDIF}
  ;

{$B-}    // Enable short circuit evaluation.
{$T-}    // Disable typechecking on @

const COMPONENT_VERSION = '4.08';

//=============================================================================
// Change this if you need more than 256 fields in a table.
const
     KBM_MAX_FIELDS=256;
//=============================================================================

//***********************************************************************

const
     // Key buffer types.
     kbmkbMin=0;
     kbmkbKey=0;
     kbmkbRangeStart=1;
     kbmkbRangeEnd=2;
     kbmkbMasterDetail=3;
     kbmkbMax=3;

     // Field flags.
     kbmffIndirect = $01;
     kbmffCompress = $02;
     kbmffModified = $04;

     // Record identifier.
     kbmRecordIdent=$6A1B2C3E;

     // Consts for GetRows
     kbmBookmarkCurrent = $00000000;
     kbmBookmarkFirst = $00000001;
     kbmBookmarkLast = $00000002;
     kbmGetRowsRest = $FFFFFFFF;

     // Const for field flags.
     kbmffNull    = #00;
     kbmffUnknown = #01;
     kbmffData    = #02;

     // Internal index names.
     kbmRowOrderIndex = '__MT__ROWORDER';
     kbmDefSortIndex  = '__MT__DEFSORT';
     kbmAutoIndex     = '__MT__AUTO_';

     // Record flags.
     kbmrfInTable          = $01;  // 0000 0001    Is record a work record or actually from the table.
     kbmrfDontCheckPoint   = $02;  // 0000 0010    Is record marked for not to checkpoint.

{$IFDEF LINUX}
     INFINITE = LongWord($FFFFFFFF);
{$ENDIF}

type
  // Define error classes and error groups.
  EMemTableError = class(EDataBaseError);

  EMemTableFatalError = class(EMemTableError);
  EMemTableInvalidRecord = class(EMemTableFatalError);

  EMemTableIndexError = class(EMemTableError);
  EMemTableDupKey = class(EMemTableError);

  EMemTableFilterError = class(EMemTableError);

  EMemTableLocaleError = class(EMemTableError);
  EMemTableInvalidLocale = class(EMemTableLocaleError);

  TkbmCustomMemTable = class;
  TkbmCustomDeltaHandler = class;

{$IFDEF DOTNET}
  TkbmRecord=class;
  PkbmRecord=TkbmRecord;
{$ELSE}
  PkbmRecord=^TkbmRecord;
{$ENDIF}

  PBookmarkFlag=^TBookmarkFlag;
  TkbmBookmark=record
      Bookmark:PkbmRecord;
      Flag:TBookmarkFlag;
  end;
  PkbmBookmark=^TkbmBookmark;
  TkbmUserBookmark=record
      Bookmark:PkbmRecord;
      DataID:longint;
  end;
  PkbmUserBookmark=^TkbmUserBookmark;

{$IFNDEF USE_FAST_LIST}
  TkbmList = TList;
{$ENDIF}

  // IndexFieldOptions.
  TkbmifoOption = (mtifoDescending,mtifoCaseInsensitive,mtifoPartial,mtifoIgnoreNull,mtifoIgnoreLocale);
  TkbmifoOptions = set of TkbmifoOption;

  TkbmIndex=class;

{$IFDEF DOTNET}
  TkbmRecord=class
  public
{$ELSE}
  TkbmRecord=record
{$ENDIF}
{$IFDEF DO_CHECKRECORD}
      StartIdent:longint;
{$ENDIF}

      RecordNo: integer;      // Will be set on every single getrecord call.
      RecordID: integer;
      UniqueRecordID: integer;

      Flag:byte;              // Record flags.
      UpdateStatus:TUpdateStatus;

      TransactionLevel:integer;
      Tag:longint;
      PrevRecordVersion:PkbmRecord;

      // Data starts at place pointed at by data, right after the end of TkbmRecord.
{$IFDEF DOTNET}
      Data:array of byte;
{$ELSE}
      Data:PChar;
{$ENDIF}

{$IFDEF DO_CHECKRECORD}
      EndIdent:longint;
{$ENDIF}
  end;

{
  Internal Data layout:
+------------+------------------------+-----------------------+------------------+----------------------+
| TkbmRecord | FIXED LENGTH DATA      | CALCULATED FIELDS     |Bookmark arrays   | VARIABLE LENGTH PTRS |
|            | FFixedRecordSize bytes | FCalcRecordSize bytes |FBookmarkArraySize| FVarLengthRecordSize |
+------------+------------------------+-----------------------+------------------+----------------------+
             ^                        ^                       ^                  ^
             GetFieldPointer          StartCalculated         StartBookmarks     StartVarLength

Blobsfields in the internal buffer are pointers to the blob data.
}

  PDateTimeRec=^TDateTimeRec;
  PWordBool=^WordBool;

  TkbmMemTableStorageType = (mtstDataSet,mtstStream,mtstBinaryStream,mtstFile,mtstBinaryFile);

  TkbmMemTableUpdateFlag = (mtufEdit,mtufAppend,mtufDontClear);
  TkbmMemTableUpdateFlags = set of TkbmMemTableUpdateFlag;

  TkbmFieldTypes = set of TFieldType;

  TkbmMemTableCompareOption = (mtcoDescending,mtcoCaseInsensitive,mtcoPartialKey,mtcoIgnoreNullKey,mtcoIgnoreLocale,mtcoUnique,mtcoNonMaintained);
  TkbmMemTableCompareOptions = set of TkbmMemTableCompareOption;

  TkbmMemTableCopyTableOption = (mtcpoStructure,mtcpoOnlyActiveFields,mtcpoProperties,mtcpoLookup,mtcpoCalculated,mtcpoAppend,mtcpoFieldIndex,mtcpoDontDisableIndexes,mtcpoIgnoreErrors{$IFDEF LEVEL6},mtcpoStringAsWideString,mtcpoWideStringUTF8{$ENDIF});
  TkbmMemTableCopyTableOptions = set of TkbmMemTableCopyTableOption;

  TkbmOnFilterIndex = procedure(DataSet:TDataSet; Index:TkbmIndex; var Accept:boolean) of object;

{$IFDEF DOTNET}
  TkbmBlobByteData = array of Byte;
  PkbmVarLength=class
  private
     FSize:integer;
     FData:TkbmBlobByteData;
  public
     constructor Create(ASize:integer); virtual;
     destructor Destroy; override;

     property Size:integer read FSize;
     property Data:TkbmBlobByteData read FData;
  end;
  PPkbmVarLength=PkbmVarLength;

  PLongint=^Longint;
  PDouble=^Double;
  PSmallInt=^SmallInt;
  PInt64=^Int64;
  PWord=^Word;
  PSQLTimeStamp=^TSQLTimeStamp;
  Pbcd=^TBCD;
{$ELSE}
  PkbmVarLength=PChar;
  PPkbmVarLength=^PkbmVarLength;
{$ENDIF}

  TkbmIndexType = (mtitNonSorted,mtitSorted);

  TkbmFieldList = class
  private
     FCount:integer;
  public
     FieldOfs:array [0..KBM_MAX_FIELDS-1] of integer;
     FieldNo:array [0..KBM_MAX_FIELDS-1] of integer;
     Fields:array [0..KBM_MAX_FIELDS-1] of TField;
     Options:array [0..KBM_MAX_FIELDS-1] of TkbmifoOptions;

     destructor Destroy; override;
     function Add(AField:TField; AValue:TkbmifoOptions):Integer;
     procedure Clear; virtual;
     function IndexOf(Item:TField): Integer;
     procedure AssignTo(AFieldList:TkbmFieldList);
     procedure MergeOptionsTo(AFieldList:TkbmFieldList); // Must be identical fieldlists.
     procedure ClearOptions;
     property Count: Integer read FCount;
  end;

  TkbmIndex = class
  private
     FName:             string;
     FReferences:       TkbmList;
     FDataSet:          TkbmCustomMemTable;
     FIndexFields:      string;
     FIndexFieldList:   TkbmFieldList;
     FIndexOptions:     TkbmMemTableCompareOptions;
     FOrdered:          boolean;
     FType:             TkbmIndexType;
     FRowOrder:         boolean;
     FInternal:         boolean;
     FIndexOfs:         integer;
     FIsView:           boolean;
     FIsFiltered:       boolean;
     FEnabled:          boolean;
     FUpdateStatus:     TUpdateStatusSet;
{$IFDEF LEVEL5}
     FFilterParser:     TExprParser;
{$ENDIF}
     FFilterFunc:       TkbmOnFilterIndex;

     procedure InternalSwap(const I,J:integer);
{$IFDEF USE_FAST_QUICKSORT}
     procedure InternalInsertionSort(const Lo,Hi:integer);
     procedure InternalFastQuickSort(const L,R:Integer);
{$ENDIF}
     procedure SetEnabled(AValue:boolean);
  protected
     function CompareRecords(const AFieldList:TkbmFieldList; const KeyRecord,ARecord:PkbmRecord; const SortCompare,Partial:boolean): Integer;
{$IFDEF USE_FAST_QUICKSORT}
     procedure FastQuickSort(const L,R:Integer);
{$ELSE}
     procedure QuickSort(L,R:Integer);
{$ENDIF}
     function BinarySearchRecordID(FirstNo,LastNo:integer; const RecordID:integer; const Desc:boolean; var Index:integer):integer;
     function SequentialSearchRecordID(const FirstNo,LastNo:integer; const RecordID:integer; var Index:integer):integer;
     function BinarySearch(FieldList:TkbmFieldList; FirstNo,LastNo:integer; const KeyRecord:PkbmRecord; const First,Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
     function SequentialSearch(FieldList:TkbmFieldList; const FirstNo,LastNo:integer; const KeyRecord:PkbmRecord; const Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
     function FindRecordNumber(const RecordBuffer:{$IFDEF DOTNET}TBytes{$ELSE}PChar{$ENDIF}):integer;
     function Filter(const ARecord:PkbmRecord):boolean;

  public
     constructor Create(Name:string;DataSet:TkbmCustomMemtable; Fields:string; Options:TkbmMemTableCompareOptions; IndexType:TkbmIndexType; Internal:boolean); {$IFDEF LEVEL5}overload;{$ENDIF}
{$IFDEF LEVEL5}
     constructor Create(IndexDef:TIndexDef;DataSet:TkbmCustomMemtable); overload;
{$ELSE}
     constructor CreateByIndexDef(IndexDef:TIndexDef;DataSet:TkbmCustomMemtable);
{$ENDIF}

     destructor Destroy; override;

     function Search(FieldList:TkbmFieldList; KeyRecord:PkbmRecord; Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
     function SearchRecord(KeyRecord:PkbmRecord; var Index:integer; RespectFilter:boolean):integer;
     function SearchRecordID(RecordID:integer; var Index:integer):integer;
     procedure Clear;
     procedure LoadAll;
     procedure ReSort;
     procedure Rebuild;

     property Enabled:boolean read FEnabled write SetEnabled;
     property IsView:boolean read FIsView write FIsView;
     property IsOrdered:boolean read FOrdered write FOrdered;
     property IsFiltered:boolean read FIsFiltered write FIsFiltered;
     property IndexType:TkbmIndexType read FType write FType;
     property IndexOptions:TkbmMemTableCompareOptions read FIndexOptions write FIndexOptions;
     property IndexFields:string read FIndexFields write FIndexFields;
     property IndexFieldList:TkbmFieldList read FIndexFieldList write FIndexFieldList;
     property Dataset:TkbmCustomMemTable read FDataSet write FDataSet;
     property Name:string read FName write FName;
     property References:TkbmList read FReferences write FReferences;
     property IsRowOrder:boolean read FRowOrder write FRowOrder;
     property IsInternal:boolean read FInternal write FInternal;
     property IndexOfs:integer read FIndexOfs write FIndexOfs;
     property UpdateStatus:TUpdateStatusSet read FUpdateStatus write FUpdateStatus;
  end;

  TkbmIndexUpdateHow = (mtiuhInsert,mtiuhEdit,mtiuhDelete);

  TkbmIndexes = class
  private
     FRowOrderIndex:  TkbmIndex;
     FIndexes:        TStringList;
     FDataSet:        TkbmCustomMemTable;

  public
     constructor Create(ADataSet:TkbmCustomMemTable);
     destructor Destroy; override;

     procedure Clear;
     procedure Add(const IndexDef:TIndexDef);

     procedure AddIndex(const Index:TkbmIndex);
     procedure DeleteIndex(const Index:TkbmIndex);

     procedure ReBuild(const IndexName:string);
     procedure Delete(const IndexName:string);
     function Get(const IndexName:string):TkbmIndex;
     function GetIndex(const Ordinal:integer):TkbmIndex;
     procedure Empty(const IndexName:string);

     function GetByFieldNames(FieldNames:string):TkbmIndex;

     procedure EmptyAll;
     procedure ReBuildAll;
     procedure MarkAllDirty;

     procedure CheckRecordUniqueness(const ARecord,ActualRecord:PkbmRecord);
     procedure ReflectToIndexes(const How:TkbmIndexUpdateHow; const OldRecord,NewRecord:PkbmRecord; const RecordPos:integer; const DontVersion:boolean);
     function Search(const FieldList:TkbmFieldList; const KeyRecord:PkbmRecord; const Nearest,RespectFilter,AutoAddIdx:boolean; var Index:integer; var Found:boolean):integer;
     function  Count:integer;
  end;

  TkbmVersioningMode = (mtvm1SinceCheckPoint,mtvmAllSinceCheckPoint);

  TkbmProgressCode = (mtpcLoad,mtpcSave,mtpcEmpty,mtpcPack,mtpcCheckPoint,mtpcSearch,mtpcCopy,mtpcUpdate,mtpcSort);
  TkbmProgressCodes = set of TkbmProgressCode;

  TkbmState = (mtstBrowse,mtstLoad,mtstSave,mtstEmpty,mtstPack,mtstCheckPoint,mtstSearch,mtstUpdate,mtstSort);

  TkbmPerformance = (mtpfFast,mtpfBalanced,mtpfSmall);

  TkbmOnProgress = procedure(DataSet:TDataSet; Percentage:integer; Code:TkbmProgressCode) of object;
  TkbmOnLoadRecord = procedure(DataSet:TDataSet; var Accept:boolean) of object;
  TkbmOnLoadField = procedure(DataSet:TDataSet; FieldNo:integer; Field:TField) of object;
  TkbmOnSaveRecord = procedure(DataSet:TDataSet; var Accept:boolean) of object;
  TkbmOnSaveField = procedure(DataSet:TDataSet; FieldNo:integer; Field:TField) of object;
  TkbmOnCompressField = procedure(DataSet:TDataSet; Field:TField; const Buffer:PChar; var Size:longint; var ResultBuffer:PChar) of object;
  TkbmOnDecompressField = procedure(DataSet:TDataSet; Field:TField; const Buffer:PChar; var Size:longint; var ResultBuffer:PChar) of object;
  TkbmOnSave = procedure(DataSet:TDataSet; StorageType:TkbmMemTableStorageType; Stream:TStream) of object;
  TkbmOnLoad = procedure(DataSet:TDataSet; StorageType:TkbmMemTableStorageType; Stream:TStream) of object;
  TkbmOnCompareFields = procedure(DataSet:TDataSet; AFld:TField; KeyField,AField:pointer; FieldType:TFieldType; Options:TkbmifoOptions; var FullCompare:boolean; var Result:integer) of object;
  TkbmOnSetupField = procedure(DataSet:TDataSet; Field:TField; var FieldFlags:byte) of object;
  TkbmOnSetupFieldProperties = procedure(DataSet:TDataSet; Field:TField) of object;

{$IFDEF LEVEL3}
  TUpdateStatusSet = set of TUpdateStatus;
{$ENDIF}

  TkbmLocaleID = integer;

  TkbmStreamFlagData                = (sfSaveData,sfLoadData);
  TkbmStreamFlagCalculated          = (sfSaveCalculated,sfLoadCalculated);
  TkbmStreamFlagLookup              = (sfSaveLookup,sfLoadLookup);
  TkbmStreamFlagNonVisible          = (sfSaveNonVisible,sfLoadNonVisible);
  TkbmStreamFlagBlobs               = (sfSaveBlobs,sfLoadBlobs);
  TkbmStreamFlagDef                 = (sfSaveDef,sfLoadDef);
  TkbmStreamFlagIndexDef            = (sfSaveIndexDef,sfLoadIndexDef);
  TkbmStreamFlagFiltered            = (sfSaveFiltered);
  TkbmStreamFlagIgnoreRange         = (sfSaveIgnoreRange);
  TkbmStreamFlagIgnoreMasterDetail  = (sfSaveIgnoreMasterDetail);
  TkbmStreamFlagDeltas              = (sfSaveDeltas, sfLoadDeltas);
  TkbmStreamFlagDontFilterDeltas    = (sfSaveDontFilterDeltas);
  TkbmStreamFlagAppend              = (sfSaveAppend,sfSaveInsert);
  TkbmStreamFlagFieldKind           = (sfSaveFieldKind,sfLoadFieldKind);
  TkbmStreamFlagFromStart           = (sfLoadFromStart);

  TkbmStreamFlagsData               = set of TkbmStreamFlagData;
  TkbmStreamFlagsCalculated         = set of TkbmStreamFlagCalculated;
  TkbmStreamFlagsLookup             = set of TkbmStreamFlagLookup;
  TkbmStreamFlagsNonVisible         = set of TkbmStreamFlagNonVisible;
  TkbmStreamFlagsBlobs              = set of TkbmStreamFlagBlobs;
  TkbmStreamFlagsDef                = set of TkbmStreamFlagDef;
  TkbmStreamFlagsIndexDef           = set of TkbmStreamFlagIndexDef;
  TkbmStreamFlagsFiltered           = set of TkbmStreamFlagFiltered;
  TkbmStreamFlagsIgnoreRange        = set of TkbmStreamFlagIgnoreRange;
  TkbmStreamFlagsIgnoreMasterDetail = set of TkbmStreamFlagIgnoreMasterDetail;
  TkbmStreamFlagsDeltas             = set of TkbmStreamFlagDeltas;
  TkbmStreamFlagsDontFilterDeltas   = set of TkbmStreamFlagDontFilterDeltas;
  TkbmStreamFlagsAppend             = set of TkbmStreamFlagAppend;
  TkbmStreamFlagsFieldKind          = set of TkbmStreamFlagFieldKind;
  TkbmStreamFlagsFromStart          = set of TkbmStreamFlagFromStart;

  TkbmOnCompress = procedure(Dataset:TkbmCustomMemTable; UnCompressedStream,CompressedStream:TStream) of object;
  TkbmOnDeCompress = procedure(Dataset:TkbmCustomMemTable; CompressedStream,DeCompressedStream:TStream) of object;

  TkbmDetermineLoadFieldsSituation = (dlfBeforeLoad,dlfAfterLoadDef);

  TkbmCustomStreamFormat = class(TComponent)
  private
     FOrigStream:TStream;
     FWorkStream:TStream;
     FBookmark:TBookmark;

     FOnCompress:TkbmOnCompress;
     FOnDecompress:TkbmOnDeCompress;

     FWasFiltered:boolean;
     FWasRangeActive:boolean;
     FWasMasterLinkUsed:boolean;
     FWasEnableIndexes:boolean;
     FWasPersistent:boolean;

     FsfData:                TkbmStreamFlagsData;
     FsfCalculated:          TkbmStreamFlagsCalculated;
     FsfLookup:              TkbmStreamFlagsLookup;
     FsfNonVisible:          TkbmStreamFlagsNonVisible;
     FsfBlobs:               TkbmStreamFlagsBlobs;
     FsfDef:                 TkbmStreamFlagsDef;
     FsfIndexDef:            TkbmStreamFlagsIndexDef;
     FsfFiltered:            TkbmStreamFlagsFiltered;
     FsfIgnoreRange:         TkbmStreamFlagsIgnoreRange;
     FsfIgnoreMasterDetail:  TkbmStreamFlagsIgnoreMasterDetail;
     FsfDeltas:              TkbmStreamFlagsDeltas;
     FsfDontFilterDeltas:    TkbmStreamFlagsDontFilterDeltas;
     FsfAppend:              TkbmStreamFlagsAppend;
     FsfFieldKind:           TkbmStreamFlagsFieldKind;
     FsfFromStart:           TkbmStreamFlagsFromStart;

     FOnBeforeSave:          TNotifyEvent;
     FOnAfterSave:           TNotifyEvent;
     FOnBeforeLoad:          TNotifyEvent;
     FOnAfterLoad:           TNotifyEvent;

     procedure SetVersion(AVersion:string);
  protected
{$IFDEF LEVEL4}
     SaveFields,
     LoadFields:array of integer;
{$ELSE}
     SaveFields,
     LoadFields:array [0..KBM_MAX_FIELDS] of integer;
     LoadFieldsCount,
     SaveFieldsCount:integer;
{$ENDIF}

     procedure SetIgnoreAutoIncPopulation(ADataset:TkbmCustomMemTable; Value:boolean);

     function  GetVersion:string; virtual;

     procedure DetermineSaveFields(ADataset:TkbmCustomMemTable); virtual;
     procedure BeforeSave(ADataset:TkbmCustomMemTable); virtual;
     procedure SaveDef(ADataset:TkbmCustomMemTable); virtual;
     procedure SaveData(ADataset:TkbmCustomMemTable); virtual;
     procedure Save(ADataset:TkbmCustomMemTable); virtual;
     procedure AfterSave(ADataset:TkbmCustomMemTable); virtual;

     procedure DetermineLoadFieldIDs(ADataset:TkbmCustomMemTable; AList:TStringList; Situation:TkbmDetermineLoadFieldsSituation); virtual;
     procedure DetermineLoadFields(ADataset:TkbmCustomMemTable; Situation:TkbmDetermineLoadFieldsSituation); virtual;
     procedure DetermineLoadFieldIndex(ADataset:TkbmCustomMemTable; ID:string; FieldCount:integer; OrigIndex:integer; var NewIndex:integer; Situation:TkbmDetermineLoadFieldsSituation); virtual;
     procedure BeforeLoad(ADataset:TkbmCustomMemTable); virtual;
     procedure LoadDef(ADataset:TkbmCustomMemTable); virtual;
     procedure LoadData(ADataset:TkbmCustomMemTable); virtual;
     procedure Load(ADataset:TkbmCustomMemTable); virtual;
     procedure AfterLoad(ADataset:TkbmCustomMemTable); virtual;

     property WorkStream:TStream read FWorkStream write FWorkStream;
     property OrigStream:TStream read FOrigStream write FOrigStream;

     property sfData:TkbmStreamFlagsData read FsfData write FsfData;
     property sfCalculated:TkbmStreamFlagsCalculated read FsfCalculated write FsfCalculated;
     property sfLookup:TkbmStreamFlagsLookup read FsfLookup write FsfLookup;
     property sfNonVisible:TkbmStreamFlagsNonVisible read FsfNonVisible write FsfNonVisible;
     property sfBlobs:TkbmStreamFlagsBlobs read FsfBlobs write FsfBlobs;
     property sfDef:TkbmStreamFlagsDef read FsfDef write FsfDef;
     property sfIndexDef:TkbmStreamFlagsIndexDef read FsfIndexDef write FsfIndexDef;
     property sfFiltered:TkbmStreamFlagsFiltered read FsfFiltered write FsfFiltered;
     property sfIgnoreRange:TkbmStreamFlagsIgnoreRange read FsfIgnoreRange write FsfIgnoreRange;
     property sfIgnoreMasterDetail:TkbmStreamFlagsIgnoreMasterDetail read FsfIgnoreMasterDetail write FsfIgnoreMasterDetail;
     property sfDeltas:TkbmStreamFlagsDeltas read FsfDeltas write FsfDeltas;
     property sfDontFilterDeltas:TkbmStreamFlagsDontFilterDeltas read FsfDontFilterDeltas write FsfDontFilterDeltas;
     property sfAppend:TkbmStreamFlagsAppend read FsfAppend write FsfAppend;
     property sfFieldKind:TkbmStreamFlagsFieldKind read FsfFieldKind write FsfFieldKind;
     property sfFromStart:TkbmStreamFlagsFromStart read FsfFromStart write FsfFromStart;
     property Version:string read GetVersion write SetVersion;

     property OnBeforeSave:TNotifyEvent read FOnBeforeSave write FOnBeforeSave;
     property OnAfterSave:TNotifyEvent read FOnAfterSave write FOnAfterSave;
     property OnBeforeLoad:TNotifyEvent read FOnBeforeLoad write FOnBeforeLoad;
     property OnAfterLoad:TNotifyEvent read FOnAfterLoad write FOnAfterLoad;
     property OnCompress:TkbmOnCompress read FOnCompress write FOnCompress;
     property OnDeCompress:TkbmOnDecompress read FOnDecompress write FOnDecompress;

  public
     constructor Create(AOwner:TComponent); override;
     procedure Assign(Source:TPersistent); override;
  end;

  TkbmStreamFormat = class(TkbmCustomStreamFormat)
  published
     property sfData;
     property sfCalculated;
     property sfLookup;
     property sfNonVisible;
     property sfBlobs;
     property sfDef;
     property sfIndexDef;
     property sfFiltered;
     property sfIgnoreRange;
     property sfIgnoreMasterDetail;
     property sfDeltas;
     property sfDontFilterDeltas;
     property sfAppend;
     property sfFieldKind;
     property sfFromStart;
     property Version;

     property OnBeforeLoad;
     property OnAfterLoad;
     property OnBeforeSave;
     property OnAfterSave;
     property OnCompress;
     property OnDeCompress;
  end;

  TkbmCompareHow = (chBreakNE,chBreakLT,chBreakGT,chBreakLTE,chBreakGTE);

  TkbmCommon = class
  protected
{$IFNDEF LEVEL5}
      FLock:                                  TRTLCriticalSection;
{$ELSE}
      FLock:                                  TCriticalSection;
{$ENDIF}
      FStandalone:                            boolean;
      FRecords:                               TkbmList;

      FOwner:                                 TkbmCustomMemTable;

      FFieldCount:                            integer;
      FFieldOfs:                              array [0..KBM_MAX_FIELDS-1] of integer;
      FFieldFlags:                            array [0..KBM_MAX_FIELDS-1] of byte;

      FLanguageID,
      FSubLanguageID,
      FSortID:                                integer;

      // Data identifier.
      FDataID:                                longint;

      // Setup from FLanguageID, FSubLanguageID and FSortID.
      FLocaleID:                              TkbmLocaleID;

      FBookmarkArraySize,
      FFixedRecordSize,
      FTotalRecordSize,
      FDataRecordSize,
      FCalcRecordSize,
      FVarLengthRecordSize,
      FStartCalculated,
      FStartBookmarks,
      FStartVarLength:                        longint;
      FVarLengthCount:                        integer;

      FIsDataModified:                        boolean;

      FAutoIncMin,
      FAutoIncMax:                            longint;

      // Holds the number of records marked as deleted but not yet removed (used during versioning of records).
      // Used for keeping track if any filtering should occur.
      FDeletedCount:                          longint;

      FUniqueRecordID:                        longint;
      FRecordID:                              longint;

      FPerformance:                           TkbmPerformance;

      FAttachMaxCount:                        integer;
      FAttachedTables:                        TList;

      // Holds a list of all actually deleted records for later reuse.
      FDeletedRecords:                        TkbmList;

      FVersioningMode:                        TkbmVersioningMode;
      FEnableVersioning:                      boolean;

      FTransactionLevel:                      longint;

      FThreadProtected:                       boolean;

{$IFDEF DO_CHECKRECORD}
      procedure _InternalCheckRecord(ARecord:PkbmRecord);
{$ENDIF}
      function _InternalAllocRecord:PkbmRecord;
      function _InternalCopyRecord(SourceRecord:PkbmRecord; CopyVarLengths:boolean):PkbmRecord;
      procedure _InternalCopyVarLength(SourceRecord,DestRecord:PkbmRecord; Field:TField);
      procedure _InternalCopyVarLengths(SourceRec,DestRec:PkbmRecord);
      procedure _InternalMoveRecord(SourceRecord,DestRecord:PkbmRecord);
      procedure _InternalTransferRecord(SourceRecord,DestRecord:PkbmRecord);
      procedure _InternalFreeRecordVarLengths(ARecord:PkbmRecord);
      procedure _InternalFreeRecord(ARecord:PkbmRecord; FreeVarLengths, FreeVersions:boolean);
      procedure _InternalClearRecord(ARecord:PkbmRecord);
      procedure _InternalAppendRecord(ARecord:PkbmRecord);
      procedure _InternalDeleteRecord(ARecord:PkbmRecord);
      procedure _InternalPackRecords;
      procedure _InternalEmpty;
      function  _InternalCompareRecords(const FieldList:TkbmFieldList; const MaxFields:integer; const KeyRecord,ARecord:PkbmRecord; const IgnoreNull,Partial:boolean; const How:TkbmCompareHow): Integer;

      function GetDeletedRecordsCount:integer;

      function GetFieldSize(FieldType:TFieldType; Size:longint):longint;
      function GetFieldDataOffset(Field:TField):integer;
      function GetFieldPointer(ARecord:PkbmRecord; Field:TField):{$IFDEF DOTNET}IntPtr{$ELSE}PChar{$ENDIF};

      procedure SetStandalone(Value:boolean);
      function GetStandalone:boolean;
      procedure SetAutoIncMin(Value:longint);
      function GetAutoIncMin:longint;
      procedure SetAutoIncMax(Value:longint);
      function GetAutoIncMax:longint;
      procedure SetPerformance(Value:TkbmPerformance);
      function GetPerformance:TkbmPerformance;
      procedure SetVersioningMode(Value:TkbmVersioningMode);
      function GetVersioningMode:TkbmVersioningMode;
      procedure SetEnableVersioning(Value:boolean);
      function GetEnableVersioning:boolean;
      procedure SetCapacity(Value:longint);
      function GetCapacity:longint;
      function GetTransactionLevel:integer;
      function GetIsDataModified:boolean;
      procedure SetIsDataModified(Value:boolean);
      procedure ClearModifiedFlags;
      function GetModifiedFlag(i:integer):boolean;
      procedure SetModifiedFlag(i:integer; Value:boolean);
      function GetAttachMaxCount:integer;
      procedure SetAttachMaxCount(Value:integer);
      function GetAttachCount:integer;

      function GetLanguageID:integer;
      procedure SetLanguageID(Value:integer);
      function GetSortID:integer;
      procedure SetSortID(Value:integer);
      function GetSubLanguageID:integer;
      procedure SetSubLanguageID(Value:integer);
      function GetLocaleID:TkbmLocaleID;
      procedure SetLocaleID(Value:TkbmLocaleID);

      procedure CalcLocaleID;
      function  GetUniqueDataID:longint;
  public
      constructor Create(AOwner:TkbmCustomMemTable);
      destructor Destroy; override;
      procedure Lock;
      procedure Unlock;

      function GetFieldIsVarLength(FieldType:TFieldType; Size:longint):boolean;
      function CompressFieldBuffer(Field:TField; const Buffer:pointer; var Size:longint):pointer; {$IFDEF DOTNET}unsafe;{$ENDIF}
      function DecompressFieldBuffer(Field:TField; const Buffer:pointer; var Size:longint):pointer; {$IFDEF DOTNET}unsafe;{$ENDIF}

      procedure AttachTable(ATable:TkbmCustomMemTable);
      procedure DeAttachTable(ATable:TkbmCustomMemTable);
      procedure LayoutRecord(const AFieldCount:integer);

      procedure AppendRecord(ARecord:PkbmRecord);
      procedure DeleteRecord(ARecord:PkbmRecord);
      procedure PackRecords;
      function RecordCount:integer;
      function DeletedRecordCount:integer;
      procedure Rollback;
      procedure Commit;
      procedure Undo(ARecord:PkbmRecord);

      function IsAnyTableActive:boolean;
      procedure CloseTables(Caller:TkbmCustomMemTable);
      procedure RefreshTables(Caller:TkbmCustomMemTable);
      procedure ResyncTables;
      procedure EmptyTables;
      procedure RebuildIndexes;
      procedure MarkIndexesDirty;
      procedure UpdateIndexes;
      procedure ClearIndexes;
      procedure ReflectToIndexes(const Caller:TkbmCustomMemTable; const How:TkbmIndexUpdateHow; const OldRecord,NewRecord:PkbmRecord; const RecordPos:integer; const DontVersion:boolean);

      procedure IncTransactionLevel;
      procedure DecTransactionLevel;

      property AttachMaxCount:integer read GetAttachMaxCount write SetAttachMaxCount;
      property AttachCount:integer read GetAttachCount;
      property Standalone:boolean read GetStandalone write SetStandalone;
      property AutoIncMin:longint read GetAutoIncMin write SetAutoIncMin;
      property AutoIncMax:longint read GetAutoIncMax write SetAutoIncMax;
      property Performance:TkbmPerformance read GetPerformance write SetPerformance;
      property VersioningMode:TkbmVersioningMode read GetVersioningMode write SetVersioningMode;
      property EnableVersioning:boolean read GetEnableVersioning write SetEnableVersioning;
      property Capacity:longint read GetCapacity write SetCapacity;
      property IsDataModified:boolean read GetIsDataModified write SetIsDataModified;
      property TransactionLevel:integer read GetTransactionLevel;
      property FieldModified[i:integer]:boolean read GetModifiedFlag write SetModifiedFlag;
      property LanguageID:integer read GetLanguageID write SetLanguageID;
      property SortID:integer read GetSortID write SetSortID;
      property SubLanguageID:integer read GetSubLanguageID write SetSubLanguageID;
      property LocaleID:TkbmLocaleID read GetLocaleID write SetLocaleID;
  end;

  TkbmCustomMemTable = class(TDataSet)
  protected
        FTableID:                               integer;
        FCommon:                                TkbmCommon;
        FIndexes:                               TkbmIndexes;

        FDefaultFormat:                         TkbmCustomStreamFormat;
        FCommaTextFormat:                       TkbmCustomStreamFormat;
        FPersistentFormat:                      TkbmCustomStreamFormat;
        FFormFormat:                            TkbmCustomStreamFormat;
        FAllDataFormat:                         TkbmCustomStreamFormat;

        FFilterRecord:                          PkbmRecord;
        FKeyRecord:                             PkbmRecord;
        FKeyBuffers:                            array [kbmkbMin..kbmkbMax] of PkbmRecord;
        FIgnoreReadOnly:                        boolean;
        FIgnoreAutoIncPopulation:               boolean;

        FIndexDefs:                             TIndexDefs;
        FCurIndex:                              TkbmIndex;
        FSortIndex:                             TkbmIndex;
        FEnableIndexes:                         boolean;
        FAutoAddIndexes:                        boolean;

{$IFNDEF LEVEL3}
        FDesignActivation:                      boolean;
        FInterceptActive:                       boolean;
{$ENDIF}

        FAutoUpdateFieldVariables:              boolean;

        FState:                                 TkbmState;

{$IFDEF LEVEL5}
        FFilterParser:                          TExprParser;
{$ENDIF}
        FFilterOptions:                         TFilterOptions;

        FMasterLink:                            TMasterDataLink;
        FMasterLinkUsed:                        boolean;
        FIsOpen:                                Boolean;
        FRecNo:                                 longint;
        FReposRecNo:                            longint;
        FInsertRecNo:                           longint;

        FBeforeCloseCalled:                     boolean;
        FDuringAfterOpen:                       boolean;

        FLoadLimit:                             longint;
        FLoadCount:                             longint;
        FLoadedCompletely:                      boolean;

        FSaveLimit:                             longint;
        FSaveCount:                             longint;
        FSavedCompletely:                       boolean;

        FDeltaHandler:                          TkbmCustomDeltaHandler;

        FOverrideActiveRecordBuffer:            PkbmRecord;
        FStatusFilter:                          TUpdateStatusSet;

        FAttachedTo:                            TkbmCustomMemTable;
        FAttachedAutoRefresh:                   boolean;

        FAutoIncField:                          TField;

        FRecalcOnFetch:                         boolean;

        FReadOnly:                              boolean;

        FPersistent:                            boolean;
        FPersistentFile:                        TFileName;
        FPersistentSaved:                       boolean;
        FPersistentBackup:                      boolean;
        FPersistentBackupExt:                   string;

        FStoreDataOnForm:                       boolean;
        FTempDataStorage:                       TMemoryStream;

        FDummyStr:                              string;

        FMasterIndexList:                       TkbmFieldList;
        FDetailIndexList:                       TkbmFieldList;
        FIndexList:                             TkbmFieldList;
        FRecalcOnIndex:                         boolean;
        FIndexFieldNames:                       string;
        FDetailFieldNames:                      string;
        FIndexName:                             string;
        FSortFieldNames:                        string;
        FAutoReposition:                        boolean;

        FRangeActive:                           boolean;
        FRangeIgnoreNullKeyValues:              boolean;

        FSortedOn:                              string;
        FSortOptions:                           TkbmMemTableCompareOptions;

        FOnCompareFields:                       TkbmOnCompareFields;

        FOnSave:                                TkbmOnSave;
        FOnLoad:                                TkbmOnLoad;

        FProgressFlags:                         TkbmProgressCodes;
        FOnProgress:                            TkbmOnProgress;

        FOnLoadRecord:                          TkbmOnLoadRecord;
        FOnSaveRecord:                          TkbmOnSaveRecord;
        FOnLoadField:                           TkbmOnLoadField;
        FOnSaveField:                           TkbmOnSaveField;

        FOnCompressBlobStream:                  TkbmOnCompress;
        FOnDecompressBlobStream:                TkbmOnDecompress;

        FOnSetupField:                          TkbmOnSetupField;
        FOnSetupFieldProperties:                TkbmOnSetupFieldProperties;
        FOnCompressField:                       TkbmOnCompressField;
        FOnDecompressField:                     TkbmOnDecompressField;

        FBeforeInsert:                          TDatasetNotifyEvent;

        FOnFilterIndex:                         TkbmOnFilterIndex;

        // Performance optimized.
        FIsFiltered:                            boolean;

        procedure _InternalBeforeInsert(DataSet:TDataSet);

        function GetActiveRecord:PkbmRecord;

        procedure _InternalFirst; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure _InternalLast; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        function  _InternalNext(ForceUseFilter:boolean):boolean; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        function  _InternalPrior(ForceUseFilter:boolean):boolean; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};

        procedure SetMasterFields(const Value: string);
        procedure SetDetailFields(const Value: string);
        function GetMasterFields: string;
        procedure SetDataSource(Value: TDataSource);

        procedure SetIsFiltered; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        property IsFiltered:boolean read FIsFiltered;
{$IFDEF LEVEL5}
        procedure BuildFilter(var AFilterParser:TExprParser; AFilter:string; AFilterOptions:TFilterOptions);
        function ParseFilter(FilterExpr:TExprParser):variant;
        procedure FreeFilter(var AFilterParser:TExprParser);
{$ENDIF}
        procedure DrawAutoInc;
        procedure PostAutoInc;

        function GetVersion:string;
        procedure SetIndexFieldNames(FieldNames:string);
        procedure SetIndexName(IndexName:string);
        procedure SetIndexDefs(Value:TIndexDefs);
        procedure SetCommaText(AString: String);
        function GetCommaText: String;
        function GetIndexByName(IndexName:string):TkbmIndex;
        function GetIndexField(Index:integer):TField;
        procedure SetIndexField(Index:integer; Value:TField);
        procedure SetAttachedTo(Value:TkbmCustomMemTable);
        procedure SetRecordTag(Value:longint);
        function GetRecordTag:longint;
        function GetIsVersioning:boolean;
        procedure SetStatusFilter(const Value:TUpdateStatusSet);
        procedure SetDeltaHandler(AHandler:TkbmCustomDeltaHandler);
        procedure SetAllData(AVariant:variant);
        function GetAllData:variant;
        function GetAutoIncValue:longint;
        function GetAutoIncMin:longint;
        procedure SetAutoIncMinValue(AValue:longint);
        procedure SetAutoUpdateFieldVariables(AValue:boolean);
        function GetPerformance:TkbmPerformance;
        procedure SetPerformance(AValue:TkbmPerformance);
        function GetVersioningMode:TkbmVersioningMode;
        procedure SetVersioningMode(AValue:TkbmVersioningMode);
        function GetEnableVersioning:boolean;
        procedure SetEnableVersioning(AValue:boolean);
        function GetStandalone:boolean;
        procedure SetStandalone(AValue:boolean);
        function GetCapacity:longint;
        procedure SetCapacity(AValue:longint);
        function GetIsDataModified:boolean;
        procedure SetIsDataModified(AValue:boolean);
        function GetAttachMaxCount:integer;
        procedure SetAttachMaxCount(AValue:integer);
        function GetAttachCount:integer;

        procedure SwitchToIndex(Index:TkbmIndex);
        function GetModifiedFlags(i:integer):boolean;
        function GetIndexes:TkbmIndexes;
        function GetTransactionLevel:integer;
        function GetDeletedRecordsCount:integer;

        function GetLanguageID:integer;
        procedure SetLanguageID(Value:integer);
        function GetSortID:integer;
        procedure SetSortID(Value:integer);
        function GetSubLanguageID:integer;
        procedure SetSubLanguageID(Value:integer);
        function GetLocaleID:TkbmLocaleID;
        procedure SetLocaleID(Value:TkbmLocaleID);
{$IFDEF LEVEL4}
        procedure SetActive(Value:boolean); override;
{$ENDIF}

        procedure DoCheckInActive;

        // Protected stuff which needs to be supported in the TDataset ancestor to make things work.
        procedure InternalOpen; override;
        procedure InternalClose; override;
        procedure InternalFirst;override;
        procedure InternalLast;override;
        procedure InternalAddRecord(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}Pointer{$ENDIF}; Append: Boolean); override;
        procedure InternalDelete; override;
        procedure InternalInitRecord(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}); override;
        procedure InternalPost; override;
        procedure InternalCancel; override;
        procedure InternalEdit; override;
        {$IFNDEF LEVEL3}
        procedure InternalInsert; override;
        {$ENDIF}
        procedure InternalInitFieldDefs; override;
        procedure InternalSetToRecord(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}); override;
        procedure CheckActive; override;
        procedure CheckInActive; override;
        procedure DoBeforeClose; override;
        procedure DoBeforeOpen; override;
        procedure DoAfterOpen; override;
        procedure DoAfterPost; override;
        procedure DoAfterDelete; override;
        procedure DoOnNewRecord; override;
        procedure DoBeforePost; override;
        procedure DoOnFilterRecord(ADataset:TDataset; var AFiltered:boolean); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};

        function IsCursorOpen: Boolean; override;
        function GetCanModify: Boolean; override;
        function GetRecordSize: Word;override;
        function GetRecordCount: integer;override;
        function AllocRecordBuffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}; override;
        procedure FreeRecordBuffer(var Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}); override;
        procedure CloseBlob(Field: TField); override;
        procedure SetFieldData(Field: TField; Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}Pointer{$ENDIF}); override;
{$IFDEF LEVEL5}
{$IFNDEF DOTNET}
        procedure DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean); override;
{$ELSE}
        procedure DataConvert(Field: TField; Source, Dest: TValueBuffer; ToNative: Boolean); override;
{$ENDIF}
{$ENDIF}

{$IFNDEF LEVEL4}
        function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
{$ENDIF}
        function GetRecord(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
        function FindRecord(Restart, GoForward: Boolean): Boolean; override;
        function GetRecNo: integer;override;
        procedure SetRecNo(Value: integer);override;
        function GetIsIndexField(Field: TField): Boolean; override;
        function GetBookmarkFlag(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}): TBookmarkFlag; override;
        procedure SetBookmarkFlag(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}; Value: TBookmarkFlag); override;
        procedure GetBookmarkData(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}; {$IFDEF DOTNET}var Bookmark:TBookmark{$ELSE}Data:Pointer{$ENDIF}); override;
        procedure SetBookmarkData(Buffer: {$IFDEF DOTNET}TRecordBuffer{$ELSE}PChar{$ENDIF}; {$IFDEF DOTNET}const Bookmark:TBookmark{$ELSE}Data:Pointer{$ENDIF}); override;
        procedure InternalGotoBookmark({$IFDEF DOTNET}const Bookmark:TBookmark{$ELSE}Bookmark:Pointer{$ENDIF}); override;
        procedure InternalHandleException; override;
        function GetDataSource: TDataSource; override;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;
        procedure SetFiltered(Value:boolean); override;
        procedure SetFilterText(const Value:string); override;
        procedure SetLoadedCompletely(Value:boolean);
        procedure SetTableState(AValue:TkbmState);
        procedure CreateFieldDefs;
        procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;

{$IFDEF LEVEL5}
        procedure DataEvent(Event: TDataEvent; Info:{$IFDEF DOTNET}TObject{$ELSE}Longint{$ENDIF}); override;
{$ENDIF}
        procedure Loaded; override;

        // Internal lowlevel routines.
        procedure DefineProperties(Filer: TFiler); override;
        procedure ReadData(Stream:TStream);
        procedure WriteData(Stream:TStream);
        procedure InternalEmptyTable;

        procedure PopulateField(ARecord:PkbmRecord;Field:TField;AValue:Variant);
        procedure PopulateRecord(ARecord:PkbmRecord;Fields:string;Values:variant);
        procedure PopulateVarLength(ARecord:PkbmRecord;Field:TField;const Buffer; Size:Integer);
        function InternalBookmarkValid(Bookmark: Pointer):boolean; {$IFDEF DOTNET}unsafe;{$ENDIF}
        procedure PrepareKeyRecord(KeyRecordType:integer; Clear:boolean);
        function FilterRecord(ARecord:PkbmRecord; ForceUseFilter:boolean):Boolean;
        function FilterRange(ARecord:PkbmRecord): Boolean;
        function FilterMasterDetail(ARecord:PkbmRecord):boolean;
{$IFDEF LEVEL5}
        function FilterExpression(ARecord:PkbmRecord; AFilterParser:TExprParser):boolean;
{$ENDIF}
        procedure MasterChanged(Sender: TObject); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure MasterDisabled(Sender: TObject); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure CopyFieldProperties(Source,Destination:TField);
        procedure CopyFieldsProperties(Source,Destination:TDataSet);

        // Internal medium level routines.
        procedure InternalSaveToStreamViaFormat(AStream:TStream; AFormat:TkbmCustomStreamFormat); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure InternalLoadFromStreamViaFormat(AStream:TStream; AFormat:TkbmCustomStreamFormat); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};

        function UpdateRecords(Source,Destination:TDataSet; KeyFields:string; Count:longint; Flags:TkbmMemTableUpdateFlags):longint;
        function LocateRecord(const KeyFields:string; const KeyValues:Variant; Options:TLocateOptions):integer;
        procedure DestroyIndexes;
        procedure CreateIndexes;

        function CheckAutoInc:boolean;

        property OverrideActiveRecordBuffer:PkbmRecord read FOverrideActiveRecordBuffer write FOverrideActiveRecordBuffer;
  public
        // Public stuff which needs to be supported in the TDataset ancestor to make things work.
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        function BookmarkValid({$IFDEF DOTNET}const {$ENDIF}Bookmark: TBookmark): boolean; override;
        function CompareBookmarks({$IFDEF DOTNET}const {$ENDIF}Bookmark1, Bookmark2: TBookmark):Integer; override;
{$IFDEF LEVEL4}
        function GetFieldData(Field: TField; Buffer:{$IFDEF DOTNET}TValueBuffer{$ELSE}Pointer{$ENDIF}): Boolean; override;
        procedure SetBlockReadSize(Value: Integer); override;
        function UpdateStatus: TUpdateStatus; override;
{$ENDIF}

        function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
        function IsSequenced:Boolean; override;

        procedure SavePersistent;
        procedure LoadPersistent;

        // Public low level routines.
        procedure BuildFieldList(Dataset:TDataset; List:TkbmFieldList; const FieldNames: string);
        function FindFieldInList(List:TkbmFieldList; FieldName:String):TField;
        function IsFieldListsEqual(List1,List2:TkbmFieldList):boolean;
        function IsFieldListsBegin(List1,List2:TkbmFieldList):boolean;
        procedure SetFieldListOptions(AList:TkbmFieldList; AOptions:TkbmifoOption; AFieldNames:string);
        procedure ClearModified;

        // Public medium level routines.
        function CreateFieldAs(Field:TField):TField;
        function MoveRecord(Source, Destination: Integer): Boolean;
        function MoveCurRecord(Destination:Longint):Boolean;
        function GetVersionFieldData(Field:TField; Version:integer):variant;
        function GetVersionStatus(Version:integer):TUpdateStatus;
        function GetVersionCount:integer;
        function SetVersionFieldData(Field:TField; AVersion:integer; AValue:variant):variant;
        function SetVersionStatus(AVersion:integer; AUpdateStatus:TUpdateStatus):TUpdateStatus;

        procedure ResetAutoInc;
        procedure Progress(Pct:integer; Code:TkbmProgressCode); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        function CopyRecords(Source,Destination:TDataSet; Count:longint; IgnoreErrors:boolean{$IFDEF LEVEL6}; WideStringAsUTF8:boolean{$ENDIF}):longint; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure AssignRecord(Source,Destination:TDataSet);
        procedure Lock; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure Unlock; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure UpdateFieldVariables;

        // Public high level routines.
        function Exists:boolean;
        procedure CreateTable;
        procedure EmptyTable;
        procedure CreateTableAs(Source:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions);
        procedure DeleteTable;
        procedure PackTable;

        function AddIndex(const Name, Fields: string; Options: TIndexOptions):TkbmIndex; {$IFDEF LEVEL5}overload;{$ENDIF}
{$IFDEF LEVEL5}
        function AddIndex(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet):TkbmIndex; overload;
{$ELSE}
        function AddIndex2(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet):TkbmIndex;
{$ENDIF}

        function AddFilteredIndex(const Name, Fields: string; Options: TIndexOptions; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex {$ifdef LEVEL5} = nil{$endif}):TkbmIndex; {$IFDEF LEVEL5}overload;{$ENDIF}
{$IFDEF LEVEL5}
        function AddFilteredIndex(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex=nil):TkbmIndex; overload;
{$ELSE}
        function AddFilteredIndex2(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex):TkbmIndex;
{$ENDIF}

        procedure DeleteIndex(const Name: string);
        procedure UpdateIndexes;
        function IndexFieldCount:Integer;
        procedure StartTransaction; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure Commit; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure Rollback; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
{$IFDEF LEVEL5}
        function  TestFilter(const AFilter:string; AFilterOptions:TFilterOptions):boolean;
{$ENDIF}
        procedure Undo;

        procedure LoadFromFile(const FileName: string);
        procedure LoadFromStream(Stream:TStream);
        procedure LoadFromFileViaFormat(const FileName:string; AFormat:TkbmCustomStreamFormat);
        procedure LoadFromStreamViaFormat(Stream: TStream; AFormat:TkbmCustomStreamFormat);
        procedure SaveToFile(const FileName: string);
        procedure SaveToStream(Stream: TStream);
        procedure SaveToFileViaFormat(const FileName:string; AFormat:TkbmCustomStreamFormat);
        procedure SaveToStreamViaFormat(Stream: TStream; AFormat:TkbmCustomStreamFormat);

        procedure LoadFromDataSet(Source:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure SaveToDataSet(Destination:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions{$IFDEF LEVEL5} = []{$ENDIF}); {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
        procedure UpdateToDataSet(Destination:TDataSet; KeyFields:String; Flags:TkbmMemTableUpdateFlags); {$IFDEF LEVEL5} overload;{$ENDIF} {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
{$IFDEF LEVEL5}
        procedure UpdateToDataSet(Destination:TDataSet; KeyFields:String); overload; {$IFDEF BCB}dynamic{$ELSE}virtual{$ENDIF};
{$ENDIF}

        procedure SortDefault;
        procedure Sort(Options:TkbmMemTableCompareOptions);
        procedure SortOn(const FieldNames:string; Options:TkbmMemTableCompareOptions);
        function Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant; override;
        function LookupByIndex(const IndexName:string; const KeyValues:Variant;
                               const ResultFields:string; RespFilter:boolean):Variant;
        function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
        procedure SetKey;
        procedure EditKey;
        function GotoKey:boolean;
        function FindKey(const KeyValues:array of const): Boolean;
        function FindNearest(const KeyValues:array of const): Boolean;
        procedure ApplyRange;
        procedure CancelRange;
        procedure SetRange(const StartValues, EndValues:array of const);
        procedure SetRangeStart;
        procedure SetRangeEnd;
        procedure EditRangeStart;
        procedure EditRangeEnd;
        procedure CheckPoint;
        procedure CheckPointRecord(RecordIndex:integer);

{$IFNDEF LEVEL3}
        function GetRows(Rows:Integer; Start:Variant; Fields:Variant):Variant;
{$ENDIF}
        procedure Reset;

        property PersistentSaved:boolean read FPersistentSaved write FPersistentSaved stored false;
        property AttachedTo:TkbmCustomMemTable read FAttachedTo write SetAttachedTo;
        property AttachedAutoRefresh:boolean read FAttachedAutoRefresh write FAttachedAutoRefresh;

        property Performance:TkbmPerformance read GetPerformance write SetPerformance             default mtpfFast;

        property Filtered;
        property Filter;
        property CurIndex:TkbmIndex read FCurIndex;
        property AttachMaxCount:integer read GetAttachMaxCount write SetAttachMaxCount;
        property AttachCount:integer read GetAttachCount;
{$IFNDEF LEVEL3}
        property DesignActivation:boolean read FDesignActivation write FDesignActivation;
{$ENDIF}
        property LanguageID:integer read GetLanguageID write SetLanguageID;
        property SortID:integer read GetSortID write SetSortID;
        property SubLanguageID:integer read GetSubLanguageID write SetSubLanguageID;
        property LocaleID:TkbmLocaleID read GetLocaleID write SetLocaleID;
        property Common:TkbmCommon read FCommon;
        property AutoIncValue:longint read GetAutoIncValue;
        property AutoIncMinValue:longint read GetAutoIncMin write SetAutoIncMinValue              default 0;
        property AutoUpdateFieldVariables:boolean read FAutoUpdateFieldVariables write SetAutoUpdateFieldVariables;
        property AllData:variant read GetAllData write SetAllData;
        property StoreDataOnForm:boolean read FStoreDataOnForm write FStoreDataOnForm             default false;
        property CommaText:string read GetCommaText write SetCommaText;
        property Capacity:longint read GetCapacity write SetCapacity;
        property DeletedRecordsCount:integer read GetDeletedRecordsCount;
        property IndexFieldNames:string read FIndexFieldNames write SetIndexFieldNames;
        property IndexName:string read FIndexName write SetIndexName;
        property EnableIndexes:boolean read FEnableIndexes write FEnableIndexes                   default true;
        property AutoAddIndexes:boolean read FAutoAddIndexes write FAutoAddIndexes                default false;
        property AutoReposition:boolean read FAutoReposition write FAutoReposition                default false;
        property SortFields:string read FSortFieldNames write FSortFieldNames;
        property SortOptions:TkbmMemTableCompareOptions read FSortOptions write FSortOptions;
        property ReadOnly:boolean read FReadOnly write FReadOnly                                  default false;
        property Standalone:boolean read GetStandalone write SetStandalone                        default false;
        property IgnoreReadOnly:boolean read FIgnoreReadOnly write FIgnoreReadOnly                default false;
        property RangeActive:boolean read FRangeActive;
        property RangeIgnoreNullKeyValues:boolean read FRangeIgnoreNullKeyValues write FRangeIgnoreNullKeyValues default true;
        property PersistentFile:TFileName read FPersistentFile write FPersistentFile;
        property Persistent:boolean read FPersistent write FPersistent                            default false;
        property PersistentBackup:boolean read FPersistentBackup write FPersistentBackup;
        property PersistentBackupExt:string read FPersistentBackupExt write FPersistentBackupExt;
        property ProgressFlags:TkbmProgressCodes read FProgressFlags write FProgressFlags;
        property LoadLimit:integer read FLoadLimit write FLoadLimit                               default -1;
        property LoadCount:integer read FLoadCount;
        property LoadedCompletely:boolean read FLoadedCompletely;
        property SaveLimit:integer read FSaveLimit write FSaveLimit                               default -1;
        property SaveCount:integer read FSaveCount;
        property SavedCompletely:boolean read FSavedCompletely;
        property RecalcOnFetch:boolean read FRecalcOnFetch write FRecalcOnFetch                   default true;
        property IsFieldModified[i:integer]:boolean read GetModifiedFlags;
        property EnableVersioning:boolean read GetEnableVersioning write SetEnableVersioning      default false;
        property VersioningMode:TkbmVersioningMode read GetVersioningMode write SetVersioningMode default mtvm1SinceCheckPoint;
        property IsVersioning:boolean read GetIsVersioning;
        property StatusFilter:TUpdateStatusSet read FStatusFilter write SetStatusFilter;
        property DeltaHandler:TkbmCustomDeltaHandler read FDeltaHandler write SetDeltaHandler;
        property Indexes:TkbmIndexes read GetIndexes;
        property IndexByName[IndexName:string]:TkbmIndex read GetIndexByName;
        property IndexDefs:TIndexDefs read FIndexDefs write SetIndexDefs;
        property IndexFields[Index:Integer]:TField read GetIndexField write SetIndexField;
        property RecalcOnIndex:boolean read FRecalcOnIndex write FRecalcOnIndex                   default false;
        property FilterOptions:TFilterOptions read FFilterOptions write FFilterOptions;
        property DetailFields: string read FDetailFieldNames write SetDetailFields;
        property MasterFields: string read GetMasterFields write SetMasterFields;
        property MasterSource: TDataSource read GetDataSource write SetDataSource;
        property RecordTag: longint read GetRecordTag write SetRecordTag;
        property Version:string read GetVersion write FDummyStr;
        property IsDataModified:boolean read GetIsDataModified write SetIsDataModified;
        property TransactionLevel:integer read GetTransactionLevel;
        property TableState:TkbmState read FState write FState;
        property DefaultFormat:TkbmCustomStreamFormat read FDefaultFormat write FDefaultFormat;
        property CommaTextFormat:TkbmCustomStreamFormat read FCommaTextFormat write FCommaTextFormat;
        property PersistentFormat:TkbmCustomStreamFormat read FPersistentFormat write FPersistentFormat;
        property FormFormat:TkbmCustomStreamFormat read FFormFormat write FFormFormat;
        property AllDataFormat:TkbmCustomStreamFormat read FAllDataFormat write FAllDataFormat;
        property OnLoadRecord:TkbmOnLoadRecord read FOnLoadRecord write FOnLoadRecord;
        property OnLoadField:TkbmOnLoadField read FOnLoadField write FOnLoadField;
        property OnSaveRecord:TkbmOnSaveRecord read FOnSaveRecord write FOnSaveRecord;
        property OnSaveField:TkbmOnSaveField read FOnSaveField write FOnSaveField;
        property OnCompressBlobStream:TkbmOnCompress read FOnCompressBlobStream write FOnCompressBlobStream;
        property OnDecompressBlobStream:TkbmOnDecompress read FOnDecompressBlobStream write FOnDecompressBlobStream;
        property OnSetupField:TkbmOnSetupField read FOnSetupField write FOnSetupField;
        property OnSetupFieldProperties:TkbmOnSetupFieldProperties read FOnSetupFieldProperties write FOnSetupFieldProperties;
        property OnCompressField:TkbmOnCompressField read FOnCompressField write FOnCompressField;
        property OnDecompressField:TkbmOnDecompressField read FOnDecompressField write FOnDecompressField;
        property OnSave:TkbmOnSave read FOnSave write FOnSave;
        property OnLoad:TkbmOnLoad read FOnLoad write FOnLoad;
        property OnProgress:TkbmOnProgress read FOnProgress write FOnProgress;
        property OnCompareFields:TkbmOnCompareFields read FOnCompareFields write FOnCompareFields;
        property OnFilterIndex:TkbmOnFilterIndex read FOnFilterIndex write FOnFilterIndex;
        property BeforeOpen;
        property AfterOpen;
        property BeforeClose;
        property AfterClose;
        property BeforeInsert:TDatasetNotifyEvent read FBeforeInsert write FBeforeInsert;
        property AfterInsert;
        property BeforeEdit;
        property AfterEdit;
        property BeforePost;
        property AfterPost;
        property BeforeCancel;
        property AfterCancel;
        property BeforeDelete;
        property AfterDelete;
        property BeforeScroll;
        property AfterScroll;
        property OnCalcFields;
        property OnDeleteError;
        property OnEditError;
        property OnFilterRecord;
        property OnNewRecord;
        property OnPostError;
        property Active;
  end;

  TkbmMemTable = class(TkbmCustomMemTable)
  public
        property IgnoreReadOnly;
  published
        property Active;
{$IFNDEF LEVEL3}
        property DesignActivation;
{$ENDIF}
        property AttachedTo;
        property AttachedAutoRefresh;
        property AttachMaxCount;
        property AutoIncMinValue;
        property AutoCalcFields;
        property FieldDefs;
        property Filtered;
        property DeltaHandler;
        property EnableIndexes;
        property AutoAddIndexes;
        property AutoReposition;
        property IndexFieldNames;
        property IndexName;
        property IndexDefs;
        property RecalcOnIndex;
        property RecalcOnFetch;
        property SortFields;
        property SortOptions;
        property ReadOnly;
        property Performance;
        property Standalone;
        property PersistentFile;
        property StoreDataOnForm;
        property Persistent;
        property PersistentBackup;
        property PersistentBackupExt;
        property ProgressFlags;
        property LoadLimit;
        property LoadedCompletely;
        property SaveLimit;
        property SavedCompletely;
        property EnableVersioning;
        property VersioningMode;
        property Filter;
        property FilterOptions;
        property MasterFields;
        property DetailFields;
        property MasterSource;
        property Version;
        property LanguageID;
        property SortID;
        property SubLanguageID;
        property LocaleID;
        property DefaultFormat;
        property CommaTextFormat;
        property PersistentFormat;
        property AllDataFormat;
        property FormFormat;
        property RangeIgnoreNullKeyValues;
        property OnProgress;
        property OnLoadRecord;
        property OnLoadField;
        property OnSaveRecord;
        property OnSaveField;
        property OnCompressBlobStream;
        property OnDecompressBlobStream;
        property OnSetupField;
        property OnSetupFieldProperties;
        property OnCompressField;
        property OnDecompressField;
        property OnSave;
        property OnLoad;
        property OnCompareFields;
        property OnFilterIndex;
        property BeforeOpen;
        property AfterOpen;
        property BeforeClose;
        property AfterClose;
        property BeforeInsert;
        property AfterInsert;
        property BeforeEdit;
        property AfterEdit;
        property BeforePost;
        property AfterPost;
        property BeforeCancel;
        property AfterCancel;
        property BeforeDelete;
        property AfterDelete;
        property BeforeScroll;
        property AfterScroll;
{$IFDEF LEVEL5}
        property BeforeRefresh;
        property AfterRefresh;
{$ENDIF}
        property OnCalcFields;
        property OnDeleteError;
        property OnEditError;
        property OnFilterRecord;
        property OnNewRecord;
        property OnPostError;
  end;

  TkbmBlobStream = class(TMemoryStream)
  private
    FWorkBuffer:PkbmRecord;
    FTableRecord:PkbmRecord;

    FField: TBlobField;
    FDataSet: TkbmCustomMemTable;
    FMode:TBlobStreamMode;
    FFieldNo: Integer;
    FModified: Boolean;

    // Internal work pointers.
    FpWorkBufferField:PChar;
    FpWorkBufferBlob:PPkbmVarLength;
    FpTableRecordField:PChar;
    FpTableRecordBlob:PPkbmVarLength;

    procedure ReadBlobData;
    procedure WriteBlobData;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
{$IFDEF DOTNET}
    function Write(const Buffer: array of Byte; Offset, Count: Longint): Longint; override;
{$ELSE}
    function Write(const Buffer; Count: Longint): Longint; override;
{$ENDIF}
    procedure Truncate;
  end;

{$ifndef LINUX}
  TkbmThreadDataSet = class(TComponent)
  private
    FDataset:TDataset;
    FLockCount:integer;
    FSemaphore:THandle;
    function GetIsLocked:boolean;
    procedure SetDataset(ds:TDataset);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function TryLock(TimeOut:DWORD):TDataset;
    function Lock:TDataset;
    procedure Unlock;
    property IsLocked:boolean read GetIsLocked;
  published
    property Dataset:TDataset read FDataset write SetDataset;
  end;
{$endif}

  // Handler which user must override to provide functionality when trying to update deltas on an external database.
  TkbmDeltaHandlerGetValue = procedure(ADeltaHandler:TkbmCustomDeltaHandler; AField:TField; var AValue:variant) of object;

  TkbmCustomDeltaHandler = class(TComponent)
  private
     FOnGetValue:TkbmDeltaHandlerGetValue;
     FDataSet:TkbmCustomMemTable;
     procedure CheckDataSet;
     function GetValues(Index:integer):Variant;
     function GetOrigValues(Index:integer):Variant;
     function GetFieldCount:integer;
     function GetFieldNames(Index:integer):string;
     function GetFields(Index:integer):TField;
     function GetOrigValuesByName(Name:string):Variant;
     function GetValuesByName(Name:string):Variant;
     function GetRecordNo:longint;
     function GetUniqueRecordID:longint;
  protected
     FPRecord,FPOrigRecord:PkbmRecord;

     procedure InsertRecord(var Retry:boolean; var State:TUpdateStatus); virtual;
     procedure DeleteRecord(var Retry:boolean; var State:TUpdateStatus); virtual;
     procedure ModifyRecord(var Retry:boolean; var State:TUpdateStatus); virtual;
     procedure UnmodifiedRecord(var Retry:boolean; var State:TUpdateStatus); virtual;
     procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
     procedure Resolve; virtual;
     property DataSet:TkbmCustomMemTable read FDataSet write FDataSet;
     property FieldCount:integer read GetFieldCount;
     property OrigValues[i:integer]:Variant read GetOrigValues;
     property Values[i:integer]:Variant read GetValues;
     property OrigValuesByName[Name:string]:Variant read GetOrigValuesByName;
     property ValuesByName[Name:string]:Variant read GetValuesByName;
     property FieldNames[i:integer]:string read GetFieldNames;
     property Fields[i:integer]:TField read GetFields;
     property RecNo:longint read GetRecordNo;
     property UniqueRecID:longint read GetUniqueRecordID;
  published
     property OnGetValue:TkbmDeltaHandlerGetValue read FOnGetValue write FOnGetValue;
  end;

{$IFNDEF LEVEL6}
  PPWideChar=^PWideChar;
{$ENDIF}

  function StreamToVariant(stream:TStream):variant;
  procedure VariantToStream(AVariant:variant; stream:TStream);
  function CompareFields(const KeyField,AField:pointer; const FieldType: TFieldType; const LocaleID:TkbmLocaleID; const IndexFieldOptions:TkbmifoOptions; var FullCompare:boolean):Integer; {$IFDEF DOTNET}unsafe;{$ENDIF}

  function IndexOptions2CompareOptions(AOptions:TIndexOptions):TkbmMemTableCompareOptions;
  function CompareOptions2IndexOptions(AOptions:TkbmMemTableCompareOptions):TIndexOptions;

const
  // All supported field types.
  kbmSupportedFieldTypes:TkbmFieldTypes=[ftString,ftSmallint,ftInteger,ftWord,ftBoolean,ftFloat
                                        ,ftCurrency,ftDate,ftTime,ftDateTime,ftAutoInc,ftBCD
{$IFDEF LEVEL6}
                                        ,ftFmtBCD,ftTimeStamp
{$ENDIF}
                                        ,ftBlob,ftMemo,ftGraphic,ftFmtMemo,ftParadoxOle,ftDBaseOle
                                        ,ftTypedBinary,ftBytes,ftVarBytes
{$IFNDEF LEVEL3}
                                        ,ftFixedChar,ftWideString,ftLargeInt,ftADT,ftArray
{$ENDIF}
{$IFDEF LEVEL5}
                                        ,ftOraBlob,ftOraClob,ftGUID
{$ENDIF}
                                        ];

  // All field types which should be treated as strings during save and load.
  kbmStringTypes:TkbmFieldTypes=[ftString,ftMemo,ftFmtMemo
{$IFNDEF LEVEL3}
                                 ,ftWideString,ftFixedChar
{$ENDIF}
{$IFDEF LEVEL5}
                                 ,ftOraClob,ftGuid
{$ENDIF}
                                ];
  // All field types which should be treated as binary types during save and load.
  kbmBinaryTypes:TkbmFieldTypes=[ftBlob,ftMemo,ftGraphic,ftFmtMemo,ftParadoxOle,ftDBaseOle,
                                 ftTypedBinary,ftVarBytes,ftBytes
{$IFDEF LEVEL5}
                                 ,ftOraBlob,ftOraClob
{$ENDIF}
                                 ];

  // All field types which should be treated as blobs.
  kbmBlobTypes:TkbmFieldTypes=[ftBlob,ftMemo,ftGraphic,ftFmtMemo,ftParadoxOle,ftDBaseOle,ftTypedBinary
{$IFDEF LEVEL5}
                               ,ftOraBlob,ftOraClob
{$ENDIF}
                              ];

  // All non blob field types.
  kbmNonBlobTypes:TkbmFieldTypes=[ftString,ftSmallint,ftInteger,ftWord,ftBoolean
                                 ,ftFloat,ftCurrency,ftDate,ftTime,ftDateTime
                                 ,ftAutoInc,ftBCD
{$IFDEF LEVEL6}
                                 ,ftFmtBCD,ftTimeStamp
{$ENDIF}
                                 ,ftBytes,ftVarBytes
{$IFDEF LEVEL5}
                                 ,ftGUID
{$ENDIF}
{$IFNDEF LEVEL3}
                                 ,ftWideString,ftFixedChar,ftLargeInt,ftADT,ftArray
{$ENDIF}                         ];

  // Field types which should be stored as a variable chunk of memory.
  // Blobs are automatically treated as variable length datatypes.
  kbmVarLengthNonBlobTypes:TkbmFieldTypes=[ftString,ftBytes,ftVarBytes
{$IFNDEF LEVEL3}
                                    ,ftWideString,ftFixedChar
{$ENDIF}
                                    ];

{$IFDEF DOTNET}
  NullVarLength=nil;
{$ELSE}
  NullVarLength=PkbmVarLength(0);
{$ENDIF}

{KBMDEL
  mtifoDescending=$01;
  mtifoCaseInsensitive=$02;
  mtifoPartial=$04;
  mtifoIgnoreNull=$08;
  mtifoIgnoreLocale=$10;
}

{$IFDEF LEVEL3}
  FieldTypeNames: array[TFieldType] of string = (
    'Unknown', 'String', 'SmallInt', 'Integer', 'Word', 'Boolean', 'Float',
    'Currency', 'BCD', 'Date', 'Time', 'DateTime', 'Bytes', 'VarBytes',
    'AutoInc', 'Blob', 'Memo', 'Graphic', 'FmtMemo', 'ParadoxOle',
    'dBaseOle', 'TypedBinary', 'Cursor');
{$ENDIF}

  FieldKindNames: array[0..4] of string = (
    'Data', 'Calculated', 'Lookup', 'InternalCalc', 'Aggregate');

{$IFDEF LEVEL3}
procedure Register;
{$ENDIF}

implementation

uses
  TypInfo, IniFiles,

{$IFDEF WIN32}
  Forms,
{$ENDIF}

{$IFDEF USE_FAST_MOVE}
  kbmMove,
{$ENDIF}

{$include kbmMemRes.inc}
  DBConsts;

{$IFDEF LEVEL5}
const
  // Field mappings needed for filtering. (What field type should be compared with what internal type).
  FldTypeMap: TFieldMap = (
    ord(ftUnknown),     // ftUnknown
    ord(ftString),      // ftString
    ord(ftSmallInt),    // ftSmallInt
    ord(ftInteger),     // ftInteger
    ord(ftWord),        // ftWord
    ord(ftBoolean),     // ftBoolean
    ord(ftFloat),       // ftFloat
    ord(ftFloat),       // ftCurrency
    ord(ftBCD),         // ftBCD
    ord(ftDate),        // ftDate
    ord(ftTime),        // ftTime
    ord(ftDateTime),    // ftDateTime
    ord(ftBytes),       // ftBytes
    ord(ftVarBytes),    // ftVarBytes
    ord(ftInteger),     // ftAutoInc
    ord(ftBlob),        // fBlob
    ord(ftBlob),        // ftMemo
    ord(ftBlob),        // ftGraphic
    ord(ftBlob),        // ftFmtMemo
    ord(ftBlob),        // ftParadoxOle
    ord(ftBlob),        // ftDBaseOle
    ord(ftBlob),        // ftTypedBinary
    ord(ftUnknown),     // ftCursor
    ord(ftString),      // ftFixedChar
    ord(ftWideString),  // ftWideString
    ord(ftLargeInt),    // ftLargeInt
    ord(ftADT),         // ftADT
    ord(ftArray),       // ftArray
    ord(ftUnknown),     // ftReference
    ord(ftUnknown),     // ftDataset
    ord(ftBlob),        // ftOraBlob
    ord(ftBlob),        // ftOraClob
    ord(ftUnknown),     // ftVariant
    ord(ftUnknown),     // ftInterface
    ord(ftUnknown),     // ftIDispatch
    ord(ftGUID)         // ftGUID
{$ifdef LEVEL6}
    ,ord(ftTimeStamp),  // ftTimeStamp
    ord(ftFmtBCD)       // ftFmtBCD
{$endif}
    );
{$ENDIF}

// -----------------------------------------------------------------------------------
// General procedures.
// -----------------------------------------------------------------------------------

{$IFDEF DOTNET}
constructor PkbmVarLength.Create(ASize:integer);
begin
     inherited Create;
     FSize:=ASize;
     SetLength(FData,ASize);
end;

destructor PkbmVarLength.Destroy;
begin
     SetLength(FData,0);
     FSize:=0;
     inherited;
end;
{$ENDIF}

// Allocate a varlength.
function AllocVarLength(Size:longint):PkbmVarLength; {$IFDEF DOTNET}unsafe;{$ENDIF}
begin
{$IFDEF DOTNET}
     Result:=PkbmVarLength.Create(Size);
{$ELSE}
     GetMem(Result,Size+4);
     FillChar(Result^,Size+4,0);
     Result[0]:=Char(Size and $FF);
     Result[1]:=Char((Size shr 8) and $FF);
     Result[2]:=Char((Size shr 16) and $FF);
     Result[3]:=Char((Size shr 24) and $FF);
{$ENDIF}
end;

// Get pointer to varlength data.
{$IFDEF DOTNET}
function GetVarLengthData(AVarLength:PkbmVarLength):TkbmBlobByteData;
begin
     Result:=AVarlength.Data;
end;
{$ELSE}
function GetVarLengthData(AVarLength:PkbmVarLength):PChar;
begin
     Result:=AVarLength+4;
end;
{$ENDIF}

// Get size of varlength data.
function GetVarLengthSize(AVarLength:PkbmVarLength):longint;
begin
{$IFDEF DOTNET}
     Result:=AVarLength.Size;
{$ELSE}
     Result:=byte(AVarLength[0])+
             (byte(AVarLength[1]) shl 8)+
             (byte(AVarLength[2]) shl 16)+
             (byte(AVarLength[3]) shl 24);
{$ENDIF}
end;

// Allocate a varlength and populate it.
{$IFDEF DOTNET}
function AllocVarLengthAs(const Source:IntPtr; Size:integer):PkbmVarLength;
begin
     Result:=AllocVarLength(Size);
     Marshal.Copy(Source,Result.Data,0,Size);
end;
{$ELSE}
function AllocVarLengthAs(const Source:PChar; Size:longint):PkbmVarLength;
begin
     Result:=AllocVarLength(Size);
 {$IFNDEF USE_FAST_MOVE}
     move(Source^,GetVarLengthData(Result)^,Size);
 {$ELSE}
     FastMove(Source^,GetVarLengthData(Result)^,Size);
 {$ENDIF}
end;
{$ENDIF}

// Duplicate varlength.
function CopyVarLength(AVarLength:PkbmVarLength):PkbmVarLength;
var
   sz:longint;
begin
     sz:=GetVarLengthSize(AVarLength);
     Result:=AllocVarLength(sz);
{$IFDEF DOTNET}
     Result.FData:=AVarLength.FData;
{$ELSE}
 {$IFNDEF USE_FAST_MOVE}
     Move(GetVarLengthData(AVarLength)^,GetVarLengthData(Result)^,sz);
 {$ELSE}
     FastMove(GetVarLengthData(AVarLength)^,GetVarLengthData(Result)^,sz);
 {$ENDIF}
{$ENDIF}
end;

{$IFDEF DEBUG}
// Dump varlength.
procedure DumpVarLength(AVarLength:PkbmVarLength); {$IFDEF DOTNET}unsafe;{$ENDIF}
var
   s:string;
   i:integer;
   sz:integer;
   p:PChar;
begin
     s:='VarLength '+inttohex(longint(AVarLength),8);
     OutputDebugString(PChar(s));
     s:=inttostr(byte(AVarLength[0]))+inttostr(byte(AVarLength[1]))+
        inttostr(byte(AVarLength[2]))+inttostr(byte(AVarLength[3]));
     s:='Size data='+s;
     OutputDebugString(PChar(s));
     sz:=GetVarLengthSize(AVarLength);
     s:=' Size='+inttostr(sz);
     OutputDebugString(PChar(s));
     p:=GetVarLengthData(AVarLength);
     s:='';
     for i:=0 to sz-1 do
     begin
          s:=s+p[i];
     end;
     s:=' Data='+s;
     OutputDebugString(PChar(s));
end;
{$ENDIF}

// Free a varlength.
procedure FreeVarLength(AVarLength:PkbmVarLength);
begin
{$IFDEF DOTNET}
     SetLength(AVarLength.FData,0);
     AVarLength.FSize:=0;
{$ELSE}
     if (AVarLength <> nil) then FreeMem(AVarLength);
{$ENDIF}
end;

{$IFDEF LEVEL4}

// Extract WideString from a buffer.
function WideStringFromBuffer(ABuffer:pointer):WideString;
var
   sz:integer;
   p:PChar;
begin
     Result:='JENS';
     p:=PChar(ABuffer);
     sz:=PInteger(p)^;
     inc(p,sizeof(integer));
     SetLength(Result,sz div Sizeof(WideChar));
{$IFNDEF USE_FAST_MOVE}
     Move(p^,Pointer(Result)^,sz);
{$ELSE}
     FastMove(p^,Pointer(Result)^,sz);
{$ENDIF}
end;

// Put WideString into a buffer.
procedure WideStringToBuffer(AWideString:WideString; ABuffer:pointer);
var
   sz:integer;
   p:PChar;
begin
     sz:=length(AWideString)*sizeof(WideChar);
     p:=PChar(ABuffer);
     PInteger(p)^:=sz;
     inc(p,sizeof(integer));

{$IFNDEF USE_FAST_MOVE}
     Move(Pointer(AWideString)^,p^,sz);
{$ELSE}
     FastMove(Pointer(AWideString)^,p^,sz);
{$ENDIF}
end;

{$ENDIF} // LEVEL4

// Put contents of a stream into a variant.
{$IFDEF DOTNET}
function StreamToVariant(stream:TStream):variant;
var
   i:integer;
   b:byte;
begin
     stream.Seek(0,soBeginning);
     Result:=VarArrayCreate([0,stream.Size - 1],VarByte);
     try
        for i:=0 to stream.Size-1 do
        begin
             stream.ReadBuffer(b,1);
             Result[i]:=b;
        end;
     except
        Result:=Unassigned;
     end;
end;

// Get contents of a variant and put it in a stream.
procedure VariantToStream(AVariant:variant; stream:TStream);
var
   sz:integer;
   i:integer;
   b:integer;
begin
     // Check if variant contains data and is an array.
     if VarIsEmpty(AVariant) or VarIsNull(AVariant) or (not VarIsArray(AVariant)) then exit;

     sz:=VarArrayHighBound(AVariant,1);
     for i:=0 to sz-1 do
     begin
          b:=AVariant[i];
          stream.WriteBuffer(b,1);
     end;
end;
{$ELSE}
function StreamToVariant(stream:TStream):variant;
var
   p:PChar;
begin
     stream.Seek(0,{$ifdef LEVEL6}soBeginning{$else}0{$endif});
     Result:=VarArrayCreate([0,stream.Size - 1],VarByte);
     try
        p:=VarArrayLock(Result);
        try
           stream.ReadBuffer(p^,stream.Size);
        finally
           VarArrayUnlock(Result);
        end;
     except
        Result:=Unassigned;
     end;
end;

// Get contents of a variant and put it in a stream.
procedure VariantToStream(AVariant:variant; stream:TStream);
var
   p:PChar;
   sz:integer;
begin
     // Check if variant contains data and is an array.
     if VarIsEmpty(AVariant) or VarIsNull(AVariant) or (not VarIsArray(AVariant)) then exit;

     sz:=VarArrayHighBound(AVariant,1);
     p:=VarArrayLock(AVariant);
     try
        stream.WriteBuffer(p^,sz+1);
     finally
        VarArrayUnlock(AVariant);
     end;
end;
{$ENDIF}

// Compare two fields.
function CompareFields(const KeyField,AField:pointer; const FieldType: TFieldType; const LocaleID:TkbmLocaleID; const IndexFieldOptions:TkbmifoOptions; var FullCompare:boolean):Integer; {$IFDEF DOTNET}unsafe;{$ENDIF}
var
   p:PChar;
   l,l1:integer;
   d:Double;
{$IFNDEF LINUX}
   c:integer;
{$ENDIF}
   li1,li2:longint;
   cur1,cur2:Currency;
{$IFDEF LEVEL6}
   tssql1,tssql2:TSQLTimeStamp;
{$ENDIF}
{$IFDEF DOTNET}
   s1,s2:string;
{$ENDIF}
{$IFDEF LEVEL4}
   w1,w2:WideString;
{$ENDIF}
begin
     case FieldType of
       ftInteger,
       ftAutoInc:
          begin
             li1:=PLongint(KeyField)^;
             li2:=PLongInt(AField)^;
             if li1=li2 then Result:=0
             else if li1<li2 then Result:=-1
             else Result:=1;
             FullCompare:=true;
//outputdebugstring(PChar(format('Key=%d, Rec=%d, Res=%d',[PLongint(KeyField)^,PLongint(AField)^,Result])));
          end;
{$IFDEF LEVEL5}
       ftGUID,
{$ENDIF}
{$IFNDEF LEVEL3}
       ftFixedChar,
{$ENDIF}
       ftString:
          begin
               p:=nil;
               try
                  // If partial, cut to reference length. p1=reference field value, p2=tried field value.
                  p:=AField;
                  FullCompare:=not (mtifoPartial in IndexFieldOptions);
{$IFNDEF DOTNET} // TODO
                  if not FullCompare then
                  begin
                       l:=StrLen(PChar(KeyField));
                       l1:=StrLen(p);
                       FullCompare:=(l=l1);
                       if not FullCompare then
                       begin
                            if l>l1 then l:=l1;
                            p:=StrAlloc(l+1);
                            StrLCopy(p,AField,l);
                       end;
                  end;
{$ENDIF}

                  if (mtifoIgnoreLocale in IndexFieldOptions) then
                  begin

                       if (mtifoCaseInsensitive in IndexFieldOptions) then
{$IFNDEF DOTNET}
 {$IFNDEF USE_FAST_STRINGCOMPARE}
                          Result:=CompareText(PChar(KeyField),p)
 {$ELSE}
                          Result:=kbmPCompStrIC(PChar(KeyField),p)
 {$ENDIF}
{$ELSE}
                          Result:=CompareText(Marshal.PtrToStringAuto(IntPtr(KeyField)),Marshal.PtrToStringAuto(IntPtr(p)))
{$ENDIF} // DOTNET
                       else
{$IFNDEF DOTNET}
 {$IFNDEF USE_FAST_STRINGCOMPARE}
                            Result:=CompareStr(String(PChar(KeyField)),String(PChar(p)));
 {$ELSE}
                            Result:=kbmPCompStr(PChar(KeyField),p);
 {$ENDIF}
{$ELSE}
                            Result:=CompareStr(Marshal.PtrToStringAuto(IntPtr(KeyField)),Marshal.PtrToStringAuto(IntPtr(p)));
{$ENDIF} // DOTNET

                  end
                  else
                  begin
{$IFDEF LINUX}
                       if (mtifoCaseInsensitive in IndexFieldOptions) then
                          Result:=AnsiCompareText(string(KeyField),string(p))
                       else
                          Result:=AnsiCompareStr(string(KeyField),string(p));
{$ELSE}
                       if (mtifoCaseInsensitive in IndexFieldOptions) then
                          c:=NORM_IGNORECASE
                       else
                           c:=0;
 {$IFNDEF DOTNET}
                       Result:=CompareString(LocaleID,c,PChar(KeyField),strlen(KeyField),p,strlen(p));
 {$ELSE}
                       s1:=Marshal.PtrToStringAuto(IntPtr(KeyField));
                       s2:=Marshal.PtrToStringAuto(IntPtr(p));
                       Result:=CompareString(LocaleID,c,s1,Length(s1),s2,Length(s2));
 {$ENDIF} // DOTNET
                       if Result=0 then
                          raise EMemTableInvalidLocale.Create(kbmInvalidLocale);
                       Result:=Result-2;
{$ENDIF}
                       if Result<=-1 then Result:=-1
                       else if Result>=1 then Result:=1
                       else Result:=0;
                  end;
               finally
{$IFNDEF DOTNET}
                  if p<>AField then StrDispose(p);
{$ENDIF}
               end;
          end;

{$IFDEF LEVEL4}
       ftWideString:
          begin
               // If partial, cut to reference length. p1=reference field value, p2=tried field value.
               w1:=WideStringFromBuffer(KeyField);
               w2:=WideStringFromBuffer(AField);
               FullCompare:=not (mtifoPartial in IndexFieldOptions);
{$IFNDEF DOTNET} // TODO
               if not FullCompare then
               begin
                    l:=Length(w2);
                    l1:=Length(w1);
                    FullCompare:=(l=l1);
                    if not FullCompare then
                    begin
                         if l>l1 then l:=l1;
                         w2:=copy(w2,1,l);
                    end;
               end;
{$ENDIF}

               if (mtifoIgnoreLocale in IndexFieldOptions) then
               begin

                    if (mtifoCaseInsensitive in IndexFieldOptions) then
{$IFNDEF DOTNET}
 {$IFNDEF LEVEL6}
                       Result:=CompareStringW(LOCALE_USER_DEFAULT,NORM_IGNORECASE,PWideChar(w1),Length(w1),PWideChar(w2),Length(w2))
 {$ELSE}
                       Result:=WideCompareText(w1,w2)
 {$ENDIF}
{$ELSE}
TODO                      Result:=WideCompareText(Marshal.PtrToStringAuto(IntPtr(KeyField)),Marshal.PtrToStringAuto(IntPtr(pw)))
{$ENDIF} // DOTNET
                    else
{$IFNDEF DOTNET}
 {$IFNDEF LEVEL6}
                         Result:=CompareStringW(LOCALE_USER_DEFAULT,0,PWideChar(w1),Length(w1),PWideChar(w2),Length(w2))
 {$ELSE}
                         Result:=WideCompareStr(w1,w2);
 {$ENDIF}
{$ELSE}
TODO                        Result:=WideCompareStr(Marshal.PtrToStringAuto(IntPtr(KeyField)),Marshal.PtrToStringAuto(IntPtr(p)));
{$ENDIF} // DOTNET

               end
               else
               begin
{$IFDEF LINUX}
                    if (mtifoCaseInsensitive in IndexFieldOptions) then
                       Result:=WideCompareText(w1,w2)
                    else
                         Result:=WideCompareStr(w1,w2);
{$ELSE}
                    if (mtifoCaseInsensitive in IndexFieldOptions) then
                       c:=NORM_IGNORECASE
                    else
                        c:=0;
{$IFNDEF DOTNET}
                    Result:=CompareStringW(LocaleID,c,PWideChar(w1),Length(w1),PWideChar(w2),Length(w2));
{$ELSE}
                    s1:=Marshal.PtrToStringAuto(IntPtr(KeyField));
                    s2:=Marshal.PtrToStringAuto(IntPtr(p));
                    Result:=CompareString(LocaleID,c,s1,Length(s1),s2,Length(s2));
{$ENDIF} // DOTNET
                    if Result=0 then
                       raise EMemTableInvalidLocale.Create(kbmInvalidLocale);
                    Result:=Result-2;
{$ENDIF}
                    if Result<=-1 then Result:=-1
                    else if Result>=1 then Result:=1
                    else Result:=0;
               end;
          end;
{$ENDIF} // LEVEL4

       ftFloat,
       ftCurrency:
          begin
               if PDouble(KeyField)^=PDouble(AField)^ then Result:=0
               else if PDouble(KeyField)^<PDouble(AField)^ then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

       ftSmallint:
          begin
               if PSmallInt(KeyField)^=PSmallInt(AField)^ then Result:=0
               else if PSmallInt(KeyField)^<PSmallInt(AField)^ then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

{$IFNDEF LEVEL3}
       ftLargeInt:
          begin
               if PInt64(KeyField)^=PInt64(AField)^ then Result:=0
               else if PInt64(KeyField)^<PInt64(AField)^ then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;
{$ENDIF}

       ftDate:
          begin
               if PDateTimeRec(KeyField)^.Date=PDateTimeRec(AField)^.Date then Result:=0
               else if PDateTimeRec(KeyField)^.Date<PDateTimeRec(AField)^.Date then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

       ftTime:
          begin
               if PDateTimeRec(KeyField)^.Time=PDateTimeRec(AField)^.Time then Result:=0
               else if PDateTimeRec(KeyField)^.Time<PDateTimeRec(AField)^.Time then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

       ftDateTime:
          begin
               d:=PDateTimeRec(KeyField)^.DateTime-PDateTimeRec(AField)^.DateTime;
               if d<0.0 then Result:=-1
               else if d>0.0 then Result:=1
               else Result:=0;
               FullCompare:=true;
          end;

       ftWord:
          begin
               if PWord(KeyField)^=PWord(AField)^ then Result:=0
               else if PWord(KeyField)^<PWord(AField)^ then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

       ftBoolean:
          begin
               if PWordBool(KeyField)^=PWordBool(AField)^ then Result:=0
               else if PWordBool(KeyField)^<PWordBool(AField)^ then Result:=-1
               else Result:=1;
               FullCompare:=true;
          end;

{$IFDEF LEVEL6}
       ftTimeStamp:
          begin
               tssql1:=PSQLTimeStamp(KeyField)^;
               tssql2:=PSQLTimeStamp(AField)^;
               Result:=tssql1.Year-tssql2.Year;
               if Result=0 then
                  Result:=tssql1.Month-tssql2.Month;
               if Result=0 then
                  Result:=tssql1.Day-tssql2.Day;
               if Result=0 then
                  Result:=tssql1.Hour-tssql2.Hour;
               if Result=0 then
                  Result:=tssql1.Hour-tssql2.Hour;
               if Result=0 then
                  Result:=tssql1.Minute-tssql2.Minute;
               if Result=0 then
                  Result:=tssql1.Second-tssql2.Second;
               if Result=0 then
                  Result:=tssql1.Fractions-tssql2.Fractions;
               if Result<0 then Result:=-1
               else if Result>0 then Result:=1;
               FullCompare:=true;
          end;
{$ENDIF}

{$IFDEF LEVEL5}
       ftBCD
{$IFDEF LEVEL6}
       ,ftFmtBCD
{$ENDIF}
          :
          begin
               Result:=0;
               if BcdToCurr(Pbcd(keyfield)^,cur1) and BcdToCurr(pbcd(afield)^,cur2) then
               begin
                    if cur1<cur2 then result:=-1
                    else if cur1>cur2 then result:=1;
               end;
               FullCompare:=true;
          end;
{$ENDIF}
     else
         Result:=0;
     end;

     if (mtifoDescending in IndexFieldOptions) then Result:=-Result;
end;

function IndexOptions2CompareOptions(AOptions:TIndexOptions):TkbmMemTableCompareOptions;
begin
     Result:=[];
     if ixUnique in AOptions then Result:=Result + [mtcoUnique];
     if ixDescending in AOptions then Result:=Result + [mtcoDescending];
     if ixCaseInsensitive in AOptions then Result:=Result + [mtcoCaseInsensitive];
{$IFNDEF LEVEL3}
     if ixNonMaintained in AOptions then Result:=Result + [mtcoNonMaintained];
{$ENDIF}
end;

function CompareOptions2IndexOptions(AOptions:TkbmMemTableCompareOptions):TIndexOptions;
begin
     Result:=[];
     if mtcoUnique in AOptions then Result:=Result + [ixUnique];
     if mtcoDescending in AOptions then Result:=Result + [ixDescending];
     if mtcoCaseInsensitive in AOptions then Result:=Result + [ixCaseInsensitive];
{$IFNDEF LEVEL3}
     if mtcoNonMaintained in AOptions then Result:=Result + [ixNonMaintained];
{$ENDIF}
end;

// -----------------------------------------------------------------------------------
// TkbmFieldList
// -----------------------------------------------------------------------------------
destructor TkbmFieldList.Destroy;
begin
     inherited;
end;

function TkbmFieldList.Add(AField:TField; AValue:TkbmifoOptions):Integer;
begin
     Result:=FCount;
     Fields[FCount]:=AField;
     Options[FCount]:=AValue;
     inc(FCount);
end;

procedure TkbmFieldList.Clear;
begin
     FCount:=0;
end;

function TkbmFieldList.IndexOf(Item:TField):integer;
var
   i:integer;
begin
     for i:=0 to FCount-1 do
     begin
          if Fields[i]=Item then
          begin
               Result:=i;
               exit;
          end;
     end;
     Result:=-1;
end;

procedure TkbmFieldList.AssignTo(AFieldList:TkbmFieldList);
var
   i:integer;
begin
     AFieldList.Clear;
     for i:=0 to Count-1 do
     begin
          AFieldList.Fields[i]:=Fields[i];
          AFieldList.Options[i]:=Options[i];
          AFieldList.FieldOfs[i]:=FieldOfs[i];
          AFieldList.FieldNo[i]:=FieldNo[i];
     end;
     AFieldList.FCount:=FCount;
end;

procedure TkbmFieldList.MergeOptionsTo(AFieldList:TkbmFieldList);
var
   i:integer;
   n:integer;
begin
     n:=FCount;
     if n>AFieldList.FCount then n:=AFieldList.FCount;
     for i:=0 to n-1 do
         AFieldList.Options[i]:=AFieldList.Options[i] + Options[i];
end;

procedure TkbmFieldList.ClearOptions;
var
   i:integer;
   n:integer;
begin
     n:=Count;
     for i:=0 to n-1 do
         Options[i]:=[];
end;

// -----------------------------------------------------------------------------------
// TkbmCommon
// -----------------------------------------------------------------------------------
// Lowlevel record handling routines.
// Allocate space for a record structure.
{$IFDEF DOTNET}
function TkbmCommon._InternalAllocRecord:PkbmRecord; unsafe;
begin
     Result:=PkbmRecord.Create;
     SetLength(Result.Data,FDataRecordSize);
     _InternalClearRecord(Result);
end;
{$ELSE}
function TkbmCommon._InternalAllocRecord:PkbmRecord;
begin
     GetMem(Result,FTotalRecordSize);
     Result^.Data:=PChar(Result)+Sizeof(TkbmRecord);
{$IFDEF DO_CHECKRECORD}
     Result^.StartIdent:=kbmRecordIdent;
     Result^.EndIdent:=kbmRecordIdent;
{$ENDIF}
     _InternalClearRecord(Result);
{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(Result);
{$ENDIF}
end;
{$ENDIF}

{$IFDEF DO_CHECKRECORD}
// Check record validity.
procedure TkbmCommon._InternalCheckRecord(ARecord:PkbmRecord);
begin
     // Check record identifier.
     if (ARecord^.StartIdent<>kbmRecordIdent) or (ARecord^.EndIdent<>kbmRecordIdent) then
        raise EMemTableInvalidRecord.Create(kbmInvalidRecord+inttostr(integer(ARecord)));
end;
{$ENDIF}

// Free var lengths in record.
{$IFDEF DOTNET}
procedure TkbmCommon._InternalFreeRecordVarLengths(ARecord:PkbmRecord);
var
   i:integer;
   pField,pVarLength:IntPtr;
   fld:TField;
   o:TObject;
begin
     // Delete varlengths if any defined.
     if FVarLengthCount>0 then
     begin
          // Browse fields to delete varlengths.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
               begin
                    pField:=GetFieldPointer(ARecord,fld);
                    Marshal.WriteByte(pField,Byte(kbmffNull));
                    Marshal.WriteIntPtr(pVarLength,1,nil); // Skip field flag.
               end;
          end;
     end;
end;
{$ELSE}
procedure TkbmCommon._InternalFreeRecordVarLengths(ARecord:PkbmRecord);
var
   i:integer;
   pVarLength:PPkbmVarLength;
   pField:PChar;
   fld:TField;
begin
     // Delete varlengths if any defined.
     if FVarLengthCount>0 then
     begin
          // Browse fields to delete varlengths.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
               begin
                    pField:=GetFieldPointer(ARecord,fld);
                    pVarLength:=PPkbmVarLength(pField+1);
                    if (pVarLength^<>nil) then
                    begin
                         FreeVarLength(pVarLength^);
                         pVarLength^:=nil;
                         pField^:=kbmffNull;
                    end;
               end;
          end;
     end;
end;
{$ENDIF}

// Transfer temporary buffer record to storage record.
{$IFDEF DOTNET}
procedure TkbmCommon._InternalTransferRecord(SourceRecord,DestRecord:PkbmRecord);
var
   i:integer;
   pFieldSrc,pFieldDest:IntPtr;
   pVarLengthSrc,pVarLengthDest:IntPtr;
   fld:TField;
   flgSource,flgDest:byte;
begin
     // Transfer varlengths.
     // Source varlengths will be freed, but null flag retained from storage.
     if FVarLengthCount>0 then
     begin
          // Browse fields to merge varlengths.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
               begin
                    pFieldSrc:=GetFieldPointer(SourceRecord,fld);
                    pFieldDest:=GetFieldPointer(DestRecord,fld);

                    // Get field flags.
                    flgSource:=Marshal.ReadByte(pFieldSrc);
                    flgDest:=Marshal.ReadByte(pFieldDest);

                    pVarLengthSrc:=PPkbmVarLength(Integer(pFieldSrc)+1);
                    pVarLengthDest:=PPkbmVarLength(Integer(pFieldDest)+1);

                    // If source varlength, move it.
                    if (pVarLengthSrc^<>nil) then
                    begin
                         // Check if destination allocated, free it.
                         if pVarLengthDest^<>nil then
                            FreeVarLength(pVarLengthDest^);
                         pVarLengthDest^:=pVarLengthSrc^;
                         pVarLengthSrc^:=nil;
                    end

                    // Else if no source, check if indirect null.
                    else if (pFieldSrc^=kbmffNull) and (pVarLengthDest^<>nil) then
                    begin
                         FreeVarLength(pVarLengthDest^);
                         pVarLengthDest^:=nil;
                         pFieldDest^:=kbmffNull;
                    end;
               end;
          end;
     end;

     // Move fixed part of record to storage.
     _InternalMoveRecord(SourceRecord,DestRecord);
end;
{$ELSE}
procedure TkbmCommon._InternalTransferRecord(SourceRecord,DestRecord:PkbmRecord);
var
   i:integer;
   pFieldSrc,pFieldDest:PChar;
   pVarLengthSrc,pVarLengthDest:PPkbmVarLength;
   fld:TField;
begin
     // Transfer varlengths.
     // Source varlengths will be freed, but null flag retained from storage.
     if FVarLengthCount>0 then
     begin
          // Browse fields to merge varlengths.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
               begin
                    pFieldSrc:=GetFieldPointer(SourceRecord,fld);
                    pFieldDest:=GetFieldPointer(DestRecord,fld);
                    pVarLengthSrc:=PPkbmVarLength(pFieldSrc+1);
                    pVarLengthDest:=PPkbmVarLength(pFieldDest+1);

                    // If source varlength, move it.
                    if (pVarLengthSrc^<>nil) then
                    begin
                         // Check if destination allocated, free it.
                         if pVarLengthDest^<>nil then
                            FreeVarLength(pVarLengthDest^);
                         pVarLengthDest^:=pVarLengthSrc^;
                         pVarLengthSrc^:=nil;
                    end

                    // Else if no source, check if indirect null.
                    else if (pFieldSrc^=kbmffNull) and (pVarLengthDest^<>nil) then
                    begin
                         FreeVarLength(pVarLengthDest^);
                         pVarLengthDest^:=nil;
                         pFieldDest^:=kbmffNull;
                    end;
               end;
          end;
     end;

     // Move fixed part of record to storage.
     _InternalMoveRecord(SourceRecord,DestRecord);
end;
{$ENDIF}

// Deallocate space for a record.
{$IFDEF DOTNET}
procedure TkbmCommon._InternalFreeRecord(ARecord:PkbmRecord; FreeVarLengths,FreeVersions:boolean); {$IFDEF DOTNET}unsafe;{$ENDIF}
begin
     if ARecord=nil then exit;

     if FreeVarLengths then _InternalFreeRecordVarLengths(ARecord);

     // Free record data, incl. previous versioning records if any, but only if actual record in table.
     with ARecord do
     begin
           if ((Flag and kbmrfInTable)<>0) and FreeVersions and (PrevRecordVersion<>nil) then
           begin
                _InternalFreeRecord(PrevRecordVersion,FreeVarLengths,true);
                PrevRecordVersion:=nil;
           end;
           SetLength(Data,0);
     end;

     // Free record.
     ARecord.Free;
end;
{$ELSE}
procedure TkbmCommon._InternalFreeRecord(ARecord:PkbmRecord; FreeVarLengths,FreeVersions:boolean); {$IFDEF DOTNET}unsafe;{$ENDIF}
begin
     if ARecord=nil then exit;

{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(ARecord);
{$ENDIF}
     if FreeVarLengths then _InternalFreeRecordVarLengths(ARecord);

     // Free record data, incl. previous versioning records if any, but only if actual record in table.
     with ARecord^ do
     begin
           if ((Flag and kbmrfInTable)<>0) and FreeVersions and (PrevRecordVersion<>nil) then
           begin
                _InternalFreeRecord(PrevRecordVersion,FreeVarLengths,true);
                PrevRecordVersion:=nil;
           end;
           Data:=nil;
     end;

     // Free record.
     FreeMem(ARecord);
end;
{$ENDIF}

// Clear record buffer.
{$IFDEF DOTNET}
procedure TkbmCommon._InternalClearRecord(ARecord:PkbmRecord);
begin
     ARecord.RecordNo:=-1;
     ARecord.RecordID:=-1;
     ARecord.UniqueRecordID:=-1;
     ARecord.Tag:=0;
     ARecord.PrevRecordVersion:=nil;
     ARecord.TransactionLevel:=-1;
     ARecord.UpdateStatus:=usUnmodified;
     ARecord.Flag:=0;
//TODO DOTNET     FillChar(ARecord.Data,FDataRecordSize,0);
end;
{$ELSE}
procedure TkbmCommon._InternalClearRecord(ARecord:PkbmRecord);
begin
{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(ARecord);
{$ENDIF}
     ARecord^.RecordNo:=-1;
     ARecord^.RecordID:=-1;
     ARecord^.UniqueRecordID:=-1;
     ARecord^.Tag:=0;
     ARecord^.PrevRecordVersion:=nil;
     ARecord^.TransactionLevel:=-1;
     ARecord^.UpdateStatus:=usUnmodified;
     ARecord^.Flag:=0;
     FillChar(ARecord^.Data^,FDataRecordSize,0);
end;
{$ENDIF}

// Allocate space for a duplicate record, and copy the info to it.
function TkbmCommon._InternalCopyRecord(SourceRecord:PkbmRecord;CopyVarLengths:boolean):PkbmRecord;
begin
{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(SourceRecord);
{$ENDIF}

     Result:=_InternalAllocRecord;
{$IFDEF DOTNET}
     with Result do
{$ELSE}
     with Result^ do
{$ENDIF}
     begin
          _InternalMoveRecord(SourceRecord,Result);
          if CopyVarLengths then _InternalCopyVarLengths(SourceRecord,Result);
     end;
end;

// Copy a var length from one record to another.
// If destination has a var length allready, it will be deleted.
procedure TkbmCommon._InternalCopyVarLength(SourceRecord,DestRecord:PkbmRecord; Field:TField); {$IFDEF DOTNET}unsafe;{$ENDIF}
var
   pFldSrc,pFldDest:PChar;
   pVarLenSrc,pVarLenDest:PPkbmVarLength;
   pVarLenClone:PkbmVarLength;
begin
     pFldSrc:=GetFieldPointer(SourceRecord,Field);
     pFldDest:=GetFieldPointer(DestRecord,Field);

     pVarLenSrc:=PPkbmVarLength(pFldSrc+1);
     pVarLenDest:=PPkbmVarLength(pFldDest+1);

     // Check if varlength in destination, then delete.
     if (pVarLenDest^ <> nil) then
     begin
          FreeVarLength(pVarLenDest^);
          pVarLenDest^:=nil;
          pFldDest^:=kbmffNull;  // Set field value to NULL.
     end;

     // Copy varlength from source to destination.
     if (pVarLenSrc^ <> nil) then
     begin
          pVarLenClone:=CopyVarLength(pVarLenSrc^);
          pVarLenDest^:=pVarLenClone;
          pFldDest^:=kbmffData;  // Set field value to NOT NULL.
     end;
end;

// Copy var lengths from one record to another.
procedure TkbmCommon._InternalCopyVarLengths(SourceRec,DestRec:PkbmRecord);
var
   i:integer;
   fld:TField;
begin
     // Copy varlengths if any defined.
     if FVarLengthCount>0 then
     begin
          // Browse fields to copy varlengths.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
                 _InternalCopyVarLength(SourceRec,DestRec,FOwner.Fields[i]);
          end;
     end;
end;

// Compression of a field buffer.
function TkbmCommon.CompressFieldBuffer(Field:TField; const Buffer:pointer; var Size:longint):pointer; {$IFDEF DOTNET}unsafe;{$ENDIF}
{$IFDEF LEVEL4}
var
   p:PChar;
   sz:integer;
{$ENDIF}
begin
     case Field.DataType of
        ftString {$IFNDEF LEVEL3},ftFixedChar{$ENDIF}:
          begin
               // Store the 0 even if its taking up one extra byte in all cases.
               // Simplifies decompression.
{$IFDEF DOTNET}
               Size:=_LStrLen(Buffer)+1;
{$ELSE}
               Size:=strlen(PChar(Buffer))+1;
{$ENDIF}
               Result:=Buffer;
          end;
{$IFDEF LEVEL4}
        ftWideString:
          begin
               p:=PChar(Buffer);
               sz:=PInteger(p)^;

               // Return actual size of the data rather than max size.
               Size:=sz+sizeof(Integer);
               Result:=Buffer;
          end;
{$ENDIF}
        else
          begin
               Result:=Buffer;
          end;
     end;
end;

// Decompression of a field buffer.
// Since we at the time only handles strings truncated at the 0 char,
// simply return the buffer and allready known size.
function TkbmCommon.DecompressFieldBuffer(Field:TField; const Buffer:pointer; var Size:longint):pointer;
begin
     Result:=Buffer;
end;

function TkbmCommon.GetDeletedRecordsCount:integer;
begin
     Result:=DeletedRecordCount;
end;

// Move contents of one record to another.
// If not to move varlength fields, copies field contents by fieldcontents.
procedure TkbmCommon._InternalMoveRecord(SourceRecord,DestRecord:PkbmRecord);
var
   i:integer;
   fld:TField;
begin
{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(SourceRecord);
     DestRecord^.StartIdent:=kbmRecordIdent;
     DestRecord^.EndIdent:=kbmRecordIdent;
{$ENDIF}
     DestRecord^.RecordNo:=SourceRecord^.RecordNo;
     DestRecord^.RecordID:=SourceRecord^.RecordID;
     DestRecord^.UniqueRecordID:=SourceRecord^.UniqueRecordID;
     DestRecord^.UpdateStatus:=SourceRecord^.UpdateStatus;
     DestRecord^.PrevRecordVersion:=SourceRecord^.PrevRecordVersion;
     DestRecord^.TransactionLevel:=SourceRecord^.TransactionLevel;
     DestRecord^.Tag:=SourceRecord^.Tag;

     // Move fixed part of record, excluding varlengths.
{$IFNDEF USE_FAST_MOVE}
     Move(SourceRecord^.Data^,DestRecord^.Data^,FFixedRecordSize);
{$ELSE}
     FastMove(SourceRecord^.Data^,DestRecord^.Data^,FFixedRecordSize);
{$ENDIF}

     // Copy varlengths null flags.
     if (FVarLengthCount>0) then
     begin
          // Browse fields to copy varlengths nullflags.
          for i:=0 to FFieldCount-1 do
          begin
               fld:=FOwner.Fields[i];
               if (fld.FieldNo>0) and ((FFieldFlags[fld.FieldNo-1] and kbmffIndirect)<>0) then
                  GetFieldPointer(DestRecord,fld)^ := GetFieldPointer(SourceRecord,fld)^;
          end;
     end;
end;

// Compare two records.
function TkbmCommon._InternalCompareRecords(const FieldList:TkbmFieldList; const MaxFields:integer; const KeyRecord,ARecord:PkbmRecord; const IgnoreNull,Partial:boolean; const How:TkbmCompareHow): Integer;
var
   i,o:integer;
   p1,p2:PChar;
   sz1,sz2:longint;
   pv1,pv2:PkbmVarLength;
   fld:TField;
   n:integer;
   flags:byte;
   RecID:longint;
   ARec:PkbmRecord;
   ifo:TkbmifoOptions;
   FullCompare:boolean;
   fno:integer;
begin
{$IFDEF USE_SAFE_CODE}
     if (KeyRecord=nil) or (ARecord=nil) then exit;
{$ENDIF}

{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(KeyRecord);
     _InternalCheckRecord(ARecord);
{$ENDIF}

     n:=FieldList.Count;
     if (MaxFields>0) and (MaxFields<n) then n:=MaxFields;

     // Loop through all indexfields, left to right.
     FullCompare:=true;
     i:=0;
     while i<n do
     begin
          fld:=FieldList.Fields[i];
          ifo:=FieldList.Options[i];
          if How<>chBreakNE then Exclude(ifo,mtifoDescending); // $FF -
          if Partial then Include(ifo,mtifoPartial);

          // Get data for specified field for the two records.
          o:=FieldList.FieldOfs[i];
          p1:=KeyRecord^.Data;
          p2:=ARecord^.Data;
          inc(p1,o);
          inc(p2,o);

          // Check if to ignore null field in key record.
          if (p1[0]=kbmffNull) and (IgnoreNull or (mtifoIgnoreNull in ifo)) then
          begin
               inc(i);
               continue;
          end;

          // Check if both not null.
          if (p1[0]<>kbmffNull) and (p2[0]<>kbmffNull) then
          begin
               // Skip null flag.
               inc(p1);
               inc(p2);

               // Check if indirect fields.
               fno:=FieldList.FieldNo[i];
               if (fno>0) then
               begin
                    flags:=FFieldFlags[fno-1];
                    if (flags and kbmffIndirect)<>0 then
                    begin
                         pv1:=PPkbmVarLength(p1)^;
                         if pv1=nil then
                         begin
                              // Find the record in the recordlist using the unique record id.
                              RecID:=KeyRecord^.RecordID;
                              if (RecID>=0) then
                              begin
                                   ARec:=PkbmRecord(FRecords.Items[RecID]);
                                   p1:=GetFieldPointer(ARec,fld);
                                   inc(p1);
                                   pv1:=PPkbmVarLength(p1)^;
                              end
                              // If by any chance no valid recordis is found, something is really rotten.
                              else raise EMemTableInvalidRecord.Create(kbmInvalidRecord);
                         end;
                         p1:=GetVarLengthData(pv1);

                         pv2:=PPkbmVarLength(p2)^;
                         if pv2=nil then
                         begin
                              // Find the record in the recordlist using the unique record id.
                              RecID:=ARecord^.RecordID;
                              if (RecID>=0) then
                              begin
                                   ARec:=PkbmRecord(FRecords.Items[RecID]);
                                   p2:=GetFieldPointer(ARec,fld);
                                   inc(p2);
                                   pv2:=PPkbmVarLength(p2)^;
                              end
                              // If by any chance no valid recordis is found, something is really rotten.
                              else raise EMemTableInvalidRecord.Create(kbmInvalidRecord);
                         end;
                         p2:=GetVarLengthData(pv2);

                         if (flags and kbmffCompress)<>0 then
                         begin
                              sz1:=GetVarLengthSize(pv1);
                              sz2:=GetVarLengthSize(pv2);
                              if (Assigned(FOwner.FOnDecompressField)) then
                              begin
                                   FOwner.FOnDecompressField(FOwner,fld,p1,sz1,p1);
                                   FOwner.FOnDecompressField(FOwner,fld,p2,sz2,p2);
                              end
                              else
                              begin
                                   p1:=DecompressFieldBuffer(fld,p1,sz1);
                                   p2:=DecompressFieldBuffer(fld,p2,sz2);
                              end;
                         end;
                    end;
               end;

               // Compare the fields.
               if (Assigned(FOwner.FOnCompareFields)) then
               begin
                    Result:=0;
                    FOwner.FOnCompareFields(FOwner,fld,p1,p2,fld.DataType,ifo,FullCompare,Result);
               end
               else
                   Result:=CompareFields(p1,p2,fld.DataType,FLocaleID,ifo,FullCompare);
          end
          else if (p1[0]<>kbmffNull) then
          begin
               if mtifoDescending in ifo then Result:=-1 else Result:=1;
          end
          else if (p2[0]<>kbmffNull) then
          begin
               if mtifoDescending in ifo then Result:=1 else Result:=-1;
          end
          else Result:=0;

          // Check type of comparison.
          case How of
               chBreakNE:
                  begin
                       if (Result<>0) or (not FullCompare) then break;
                  end;

               chBreakGTE:
                  begin
                       if Result>=0 then break;
                  end;

               chBreakLTE:
                  begin
                       if Result<=0 then break;
                  end;

               chBreakGT:
                  begin
                       if Result>0 then break;
                  end;

               chBreakLT:
                  begin
                       if Result<0 then break;
                  end;
          end;
          inc(i);
     end;
end;

// Append record to chain of records.
procedure TkbmCommon._InternalAppendRecord(ARecord:PkbmRecord);
begin
{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(ARecord);
{$ENDIF}

     AppendRecord(ARecord);
end;

// Delete record from chain.
procedure TkbmCommon._InternalDeleteRecord(ARecord:PkbmRecord);
begin
     if ARecord=nil then exit;

{$IFDEF DO_CHECKRECORD}
     _InternalCheckRecord(ARecord);
{$ENDIF}

     DeleteRecord(ARecord);
     _InternalFreeRecord(ARecord,true,true);
end;

// Pack records.
procedure TkbmCommon._InternalPackRecords;
begin
     PackRecords;
end;

// Purge all records.
procedure TkbmCommon._InternalEmpty;
var
   i:integer;
begin
     // Remove the records.
     for i:=0 to FRecords.Count-1 do
         _InternalFreeRecord(FRecords.Items[i],true,true);

     FDeletedRecords.Clear;
     FRecordID:=0;
     FUniqueRecordID:=0;
     FRecords.Clear;
     FDataID:=GetUniqueDataID;
end;

function TkbmCommon.GetFieldSize(FieldType:TFieldType; Size:longint):longint;
begin
     case FieldType of
{$IFNDEF LEVEL3}
          ftWideString:         Result:=Size*sizeof(WideChar)+sizeof(integer); // 4 bytes length + 2 bytes/character 
          ftFixedChar,
{$ENDIF}
          ftString:             Result:=Size+1; // Size + zero end character.
{$IFDEF LEVEL5}
          ftGUID:               Result:=38+1; // 38 + zero end character.
{$ENDIF}
          ftBytes:              Result:=Size;
          ftVarBytes:           Result:=Size+SizeOf(Word);
          ftSmallInt:           Result:=SizeOf(SmallInt);
          ftInteger:            Result:=SizeOf(Integer);
{$IFNDEF LEVEL3}
          ftLargeInt:           Result:=SizeOf(Int64);
          ftADT,ftArray:        Result:=0;
{$ENDIF}
          ftWord:               Result:=SizeOf(Word);
          ftBoolean:            Result:=SizeOf(WordBool);
          ftFloat:              Result:=SizeOf(Double);
          ftCurrency:           Result:=SizeOf(Double);
          ftDate:               Result:=SizeOf(TDateTimeRec);
          ftTime:               Result:=SizeOf(TDateTimeRec);
          ftDateTime:           Result:=SizeOf(TDateTimeRec);
{$IFDEF LEVEL6}
          ftTimeStamp:          Result:=SizeOf(TSQLTimeStamp);
{$ENDIF}
          ftAutoInc:            Result:=SizeOf(Integer);
          ftBlob:               Result:=0;
          ftMemo:               Result:=0;
          ftGraphic:            Result:=0;
          ftFmtMemo:            Result:=0;
          ftParadoxOle:         Result:=0;
          ftDBaseOle:           Result:=0;
          ftTypedBinary:        Result:=0;
{$IFDEF LEVEL5}
          ftOraBlob,
          ftOraClob:            Result:=0;
{$ENDIF}
          ftBCD
{$IFDEF LEVEL6}
          ,ftFmtBCD
{$ENDIF}
                         :      Result:=34; // SizeOf(TBCD);
     else
          Result:=0;
     end;
end;

function TkbmCommon.GetFieldPointer(ARecord:PkbmRecord; Field:TField):PChar;
var
   n:integer;
begin
{$IFDEF USE_SAFE_CODE}
     Result:=nil;
     if ARecord=nil then exit;
{$ENDIF}

     Result:=ARecord^.Data;
{$IFDEF USE_SAFE_CODE}
     if Result=nil then exit;
{$ENDIF}
     n:=Field.FieldNo;
     if n>0 then
        inc(Result,FFieldOfs[n-1])
     else
        inc(Result,FStartCalculated+Field.Offset);
end;

function TkbmCommon.GetFieldDataOffset(Field:TField):integer;
var
   n:integer;
begin
     n:=Field.FieldNo;
     if n>0 then
        Result:=FFieldOfs[n-1]
     else
        Result:=FStartCalculated+Field.Offset;
end;

constructor TkbmCommon.Create(AOwner:TkbmCustomMemTable);
begin
     inherited Create;
{$IFNDEF LEVEL5}
     InitializeCriticalSection(FLock);
{$ELSE}
     FLock:=TCriticalSection.Create;
{$ENDIF}

     // Setup owner of table.
     FOwner:=AOwner;

     // Create physical list of records.
     FRecords:=TkbmList.Create;

     // Create list of deleted but not purged records.
     FDeletedRecords:=TkbmList.Create;

     // Set default data id to a random number. (max 2 bytes).
     FDataID:=GetUniqueDataID;

     // Set defaults.
     FAutoIncMin:=0;
     FAutoIncMax:=0;
     FDeletedCount:=0;
     FUniqueRecordID:=0;
     FRecordID:=0;
     FPerformance:=mtpfFast;
     FVersioningMode:=mtvm1SinceCheckPoint;
     FEnableVersioning:=false;
     FTransactionLevel:=0;

{$IFDEF LINUX}
     LocaleID:=0;
{$ELSE}
     LocaleID:=LOCALE_USER_DEFAULT;
{$ENDIF}

     // Attached tables.
     FAttachMaxCount:=1;
     FAttachedTables:=TList.Create;
end;

destructor TkbmCommon.Destroy;
var
   i:integer;
   mt:TkbmCustomMemTable;
begin
     // Check if any tables attached to this, deattach them.
     for i:=0 to FAttachedTables.Count-1 do
     begin
          mt:=TkbmCustomMemTable(FAttachedTables.Items[i]);
          if mt<>nil then
          begin
               mt.Close;
               mt.AttachedTo:=nil;
          end;
     end;

     FAttachedTables.free;
     FDeletedRecords.free;
     FRecords.free;

{$IFNDEF LEVEL5}
     DeleteCriticalSection(FLock);
{$ELSE}
     FLock.Free;
{$ENDIF}
     inherited;
end;

function TkbmCommon.GetUniqueDataID:longint;
begin
     repeat
           Result:=random(1 shl 31 + 1);
     until Result<>FDataID;
end;

procedure TkbmCommon.ClearModifiedFlags;
var
   i:integer;
begin
     Lock;
     try
        // Clear all modification flags.
        for i:=0 to KBM_MAX_FIELDS-1 do
            FFieldFlags[i]:=FFieldFlags[i] and (high(byte)-kbmffModified);
     finally
        UnLock;
     end;
end;

function TkbmCommon.GetModifiedFlag(i:integer):boolean;
begin
     Lock;
     Result:=false;
     try
        if (i<0) or (i>=FFieldCount) then raise ERangeError.CreateFmt(kbmOutOfRange,[i]);
        Result:=(FFieldFlags[i] and kbmffModified)<>0;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetModifiedFlag(i:integer; Value:boolean);
begin
     Lock;
     try
        if (i<0) or (i>=FFieldCount) then raise ERangeError.CreateFmt(kbmOutOfRange,[i]);
        if Value then
           FFieldFlags[i]:=FFieldFlags[i] and kbmffModified
        else
           FFieldFlags[i]:=FFieldFlags[i] and (high(byte)-kbmffModified);
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetAttachMaxCount:integer;
begin
     Lock;
     try
        Result:=FAttachMaxCount;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetAttachCount:integer;
var
   i:integer;
begin
     Lock;
     Result:=0;
     try
        for i:=0 to FAttachedTables.Count-1 do
            if FAttachedTables.Items[i]<>nil then inc(Result);
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetAttachMaxCount(Value:integer);
begin
     if Value=FAttachMaxCount then exit;

     if Value<1 then
        raise ERangeError.Create(kbmInvArgument);

     if IsAnyTableActive then
        raise EMemTableError.Create(kbmTableMustBeClosed);

     Lock;
     try
        FAttachedTables.count:=Value;
        FAttachMaxCount:=Value;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.CalcLocaleID;
var
   ALID:word;
begin
     Lock;
     try
        ALID:=(word(FSubLanguageID) shl 10) or word(FLanguageID);
        FLocaleID:=(FSortID shl 16) or ALID;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetLocaleID:integer;
begin
     Lock;
     try
        Result:=FLocaleID;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetLocaleID(Value:integer);
var
   ALID:word;
begin
     Lock;
     try
        FLocaleID:=Value;
        FSortID:=(FLocaleID shr 16) and $F;
        ALID:=FLocaleID and $FFFF;
        FLanguageID:=ALID and $FF;
        FSubLanguageID:=(ALID shr 10) and $FF;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetLanguageID:integer;
begin
     Lock;
     try
        Result:=FLanguageID;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetLanguageID(Value:integer);
begin
     Lock;
     try
        FLanguageID:=Value;
        CalcLocaleID;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetSortID:integer;
begin
     Lock;
     try
        Result:=FSortID;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetSortID(Value:integer);
begin
     Lock;
     try
        FSortID:=Value;
        CalcLocaleID;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetSubLanguageID:integer;
begin
     Lock;
     try
        Result:=FSubLanguageID;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetSubLanguageID(Value:integer);
begin
     Lock;
     try
        FSubLanguageID:=Value;
        CalcLocaleID;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.Lock;
begin
     if not FStandalone then
     begin
{$IFNDEF LEVEL5}
          EnterCriticalSection(FLock);
{$ELSE}
          FLock.Enter;
{$ENDIF}
     end;
end;

procedure TkbmCommon.Unlock;
begin
     if not FStandalone then
     begin
{$IFNDEF LEVEL5}
          LeaveCriticalSection(FLock);
{$ELSE}
          FLock.Leave;
{$ENDIF}
     end;
end;

// Rollback transaction.
procedure TkbmCommon.RollBack;
var
   i:integer;
   pRec:PkbmRecord;
begin
     // Loop through all records and discard newest current transactions.
     FIsDataModified:=false;
     for i:=0 to FRecords.count-1 do
     begin
          pRec:=PkbmRecord(FRecords.Items[i]);
          if pRec=nil then continue;

          // While same transaction level.
          while pRec^.TransactionLevel=FTransactionLevel do
          begin
               // Check what happened with this version.
               case pRec^.UpdateStatus of

                    // Inserted, delete it again.
                    usInserted:
                      begin
                           _InternalFreeRecord(pRec,true,true);
                           FDeletedRecords.Add(pointer(i));
                           FRecords.Items[i]:=nil;
                           pRec:=nil;
                           break;
                      end;

                    // Marked for deletion or modified, change to older version.
                    usDeleted,
                    usModified:
                      begin
                           FRecords.Items[i]:=pRec^.PrevRecordVersion;
                           _InternalFreeRecord(pRec,true,false);
                      end;

                    // Done nothing. Skip.
                    usUnmodified: break;
               end;
               pRec:=FRecords.Items[i];
          end;

          // Check if still modified, set modified flag.
          if (pRec<>nil) and (pRec^.UpdateStatus<>usUnmodified) then FIsDataModified:=true;
     end;
end;

// Commit transaction.
procedure TkbmCommon.Commit;
var
   i:integer;
   pRec,pRec1:PkbmRecord;
begin
     // Loop through all records and discard older transactions.
     for i:=0 to FRecords.count-1 do
     begin
          pRec:=PkbmRecord(FRecords.Items[i]);
          if pRec=nil then continue;

          // While same transaction level, use newest, discard rest.
          if pRec^.TransactionLevel<>FTransactionLevel then continue;

          // Keep newest version.
          pRec1:=pRec^.PrevRecordVersion;
          if (pRec1<>nil) then _InternalFreeRecord(pRec1,true,true);
          pRec^.PrevRecordVersion:=nil;

          if pRec^.TransactionLevel=FTransactionLevel then dec(pRec^.TransactionLevel);
     end;
end;

procedure TkbmCommon.Undo(ARecord:PkbmRecord);
var
   recid:integer;
   oRec:PkbmRecord;
begin
     if ARecord=nil then exit;

     Lock;
     try
        // Get the record pointer from the storage.
        recid:=ARecord^.RecordID;
        if recid<0 then exit;
        ARecord:=FRecords.Items[recid];

        // Check what happened with this version.
        case ARecord^.UpdateStatus of

             // Inserted, delete it again.
             usInserted:
               begin
                    ReflectToIndexes(nil,mtiuhDelete,ARecord,nil,ARecord^.RecordNo,true);
                    exit;
               end;

             // Marked for deletion or modified, change to older version.
             usDeleted,usModified:
               begin
                    // Figure out what status the record had before.
                    oRec:=ARecord^.PrevRecordVersion;

                    // Free references to deleted record version.
                    ReflectToIndexes(nil,mtiuhDelete,ARecord,nil,-1,true);

                    // Reinsert previous record version.
                    ReflectToIndexes(nil,mtiuhInsert,nil,oRec,oRec^.RecordNo,true);

                    // Update physical record buffer.
                    FRecords.Items[recid]:=ARecord^.PrevRecordVersion;
               end;

             // Done nothing. Skip.
             usUnmodified: exit;
        end;
     finally
        Unlock;
     end;
end;

// Return false if the field should be included as fixed size in the record.
function TkbmCommon.GetFieldIsVarLength(FieldType:TFieldType; Size:longint):boolean;
begin
     Result:=false;

     // No need to store small amounts of data or fixed length data indirectly.
     if (FieldType in kbmVarLengthNonBlobTypes) and (Size>12) then
     begin
          // If should be as fast as possible, dont go indirectly, else ok.
          if (FPerformance <> mtpfFast) then Result:=true;
     end
     else if (FieldType in kbmBlobTypes) then Result:=true;
end;

procedure TkbmCommon.SetStandalone(Value:boolean);
begin
     Lock;
     try
        if FAttachedTables.Count>1 then
           raise EMemTableError.Create(kbmChildrenAttached);
        FStandAlone:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetStandalone:boolean;
begin
     Result:=FStandalone;
end;

function TkbmCommon.RecordCount:integer;
begin
     Lock;
     try
        Result:=FRecords.Count;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.AppendRecord(ARecord:PkbmRecord);
var
   d,r:integer;
begin
     Lock;
     try
        // Check if to reuse a deleted spot.
        if FDeletedRecords.Count>0 then
        begin
             d:=FDeletedRecords.Count-1;
             r:=Integer(FDeletedRecords.Items[d]);

             // Put 'physical' record number into record.
             ARecord^.RecordID:=r;
             FDeletedRecords.Delete(d);

             // Put unique record number into record.
             ARecord^.UniqueRecordID:=FUniqueRecordID;
             inc(FUniqueRecordID);

             FRecords.Items[r]:=ARecord;
             ARecord^.Flag:=(ARecord^.Flag or kbmrfIntable);
        end
        else
        begin
             // Put 'physical' record number into record.
             ARecord^.RecordID:=FRecordID;
             inc(FRecordID);

             // Put unique record number into record.
             ARecord^.UniqueRecordID:=FUniqueRecordID;
             inc(FUniqueRecordID);

             ARecord^.Flag:=(ARecord^.Flag or kbmrfIntable);
             FRecords.Add(ARecord);

             // Check if running out of valid bookmark ID's.
             // Very unlikely (needs inserting 2 billion records), but possible.
             if FUniqueRecordID>=2147483600 then
                raise EMemTableFatalError.Create(kbmOutOfBookmarks);
        end;

        if FEnableVersioning then
           ARecord^.UpdateStatus:=usInserted;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.DeleteRecord(ARecord:PkbmRecord);
begin
     Lock;
     try
        FDeletedRecords.Add(pointer(ARecord.RecordID));
        FRecords.Items[ARecord.RecordID]:=nil;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.PackRecords;
var
   i:integer;
begin
     Lock;
     try
        FRecords.Pack;
        for i:=0 to FRecords.Count-1 do
            if FRecords.Items[i]<>nil then PkbmRecord(FRecords.Items[i])^.RecordID:=i;
        FDeletedRecords.Clear;
     finally
        Unlock;
     end;
end;

function TkbmCommon.DeletedRecordCount:integer;
begin
     Lock;
     try
        Result:=FDeletedRecords.Count;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetAutoIncMin(Value:longint);
begin
     Lock;
     try
        FAutoIncMin:=Value;
        if FAutoIncMax<FAutoIncMin then FAutoIncMax:=FAutoIncMin-1;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetAutoIncMax(Value:longint);
begin
     Lock;
     try
        FAutoIncMax:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetAutoIncMin:longint;
begin
     Result:=FAutoIncMin;
end;

function TkbmCommon.GetAutoIncMax:longint;
begin
     Result:=FAutoIncMax;
end;

procedure TkbmCommon.SetPerformance(Value:TkbmPerformance);
begin
     Lock;
     try
        FPerformance:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetPerformance:TkbmPerformance;
begin
     Result:=FPerformance;
end;

procedure TkbmCommon.SetVersioningMode(Value:TkbmVersioningMode);
begin
     Lock;
     try
        FVersioningMode:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetVersioningMode:TkbmVersioningMode;
begin
     Result:=FVersioningMode;
end;

procedure TkbmCommon.SetEnableVersioning(Value:boolean);
begin
     Lock;
     try
        FEnableVersioning:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetEnableVersioning:boolean;
begin
     Result:=FEnableVersioning;
end;

procedure TkbmCommon.SetCapacity(Value:longint);
begin
     Lock;
     try
//TODO KBM        FRecords.Capacity:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetCapacity:longint;
begin
     Lock;
     try
        Result:=FRecords.Capacity;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetIsDataModified:boolean;
begin
     Lock;
     try
        Result:=FIsDataModified;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.SetIsDataModified(Value:boolean);
begin
     Lock;
     try
        FIsDataModified:=Value;
     finally
        Unlock;
     end;
end;

function TkbmCommon.GetTransactionLevel:integer;
begin
     Lock;
     try
        Result:=FTransactionLevel;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.IncTransactionLevel;
begin
     Lock;
     try
        inc(FTransactionLevel);
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.DecTransactionLevel;
begin
     Lock;
     try
        if FTransactionLevel>0 then
           dec(FTransactionLevel);
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.DeAttachTable(ATable:TkbmCustomMemTable);
var
   i:integer;
begin
     Lock;
     try
        i:=FAttachedTables.IndexOf(ATable);
        if i>=0 then FAttachedTables.Items[i]:=nil; // Only mark as unused.
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.AttachTable(ATable:TkbmCustomMemTable);
var
   i:integer;
begin
     Lock;
     try
        // Look for unused spot.
        i:=FAttachedTables.IndexOf(nil);
        if i<0 then
        begin
             if IsAnyTableActive then
                raise EMemTableError.Create(kbmTableMustBeClosed);
             FAttachedTables.Add(ATable);
             ATable.FTableID:=FAttachedTables.Count-1;
             FAttachMaxCount:=FAttachedTables.Count;
        end
        else
        begin
             // Reuse spot.
             FAttachedTables.Items[i]:=ATable;
             ATable.FTableID:=i;
//             ClearBookmarkInfo(ATable.FTableID);
        end;
     finally
        Unlock;
     end;
end;

// Define recordlayout based on a table.
procedure TkbmCommon.LayoutRecord(const AFieldCount:integer);
  procedure EnumerateFieldDefs(SomeFieldDefs:TFieldDefs; var NbrFields:integer);
  var
     i:integer;
{$IFNDEF LEVEL3}
     j:integer;
{$ENDIF}
     sz:integer;
  begin
       with FOwner do
       begin
            for i:=0 to SomeFieldDefs.Count - 1 do
                with SomeFieldDefs[i] do
                begin
                     // Check if field type supported.
                     if not (DataType in kbmSupportedFieldTypes) then
                        raise EMemTableError.Create(kbminternalOpen1Err+
                              Name
                              {$IFNDEF LEVEL3}
                              +' ('+DisplayName+')'
                              {$ENDIF}
                              +Format(kbminternalOpen2Err,[integer(DataType)]));

                     // Determine if field is subject to being an indirect field.
                     if { (Fields[FieldNo-1].FieldKind=fkData) and  - Should not be needed since all fielddefs are datafields. }
                        GetFieldIsVarLength(DataType,Size) then
                     begin
                          FFieldFlags[NbrFields]:=FFieldFlags[NbrFields] or kbmffIndirect;

                          // Call user app. to allow override of default unless a blobtype.
                          if (Assigned(FOnSetupField)) and (not (Fields[FieldNo-1].DataType in kbmBlobTypes)) then
                             FOnSetupField(FOwner,Fields[FieldNo-1],FFieldFlags[NbrFields]);
                     end;

                     // If an indirect field (a varlength), dont set fieldofs at this time.
                     if (FFieldFlags[NbrFields] and kbmffIndirect)<>0 then
                     begin
                          FFieldOfs[NbrFields]:=-1;
                          inc(NbrFields);
                     end
                     else
                     begin
                          // Else normal fixed size field embedded in the record.
                          FFieldOfs[NbrFields]:=FFixedRecordSize;

{$IFNDEF LEVEL3}
                          // Check if arraytype field.
                          if ChildDefs.Count > 0 then
                          begin
                               inc(NbrFields);
                               sz:=GetFieldSize(DataType,Size)+1;
                               inc(FFixedRecordSize,sz);
                               if DataType = ftArray then
                                  for j:=1 to Size do EnumerateFieldDefs(ChildDefs,NbrFields)
                               else
                                   EnumerateFieldDefs(ChildDefs,NbrFields);
                          end
                          else
                          begin
                               // Look for fieldsize.
                               sz:=GetFieldSize(DataType,Size)+1;
                               inc(FFixedRecordSize,sz);
                               inc(NbrFields);
                          end;
{$ELSE}
                          // Look for fieldsize.
                          sz:=GetFieldSize(DataType,Size)+1;
                          inc(FFixedRecordSize,sz);
                          inc(NbrFields);
{$ENDIF}
                     end;
                end;
           end;
  end;

  procedure EnumerateVarLengthFieldDefs(SomeFieldDefs:TFieldDefs; var NbrFields:integer);
  var
     i:integer;
{$IFNDEF LEVEL3}
     j:integer;
{$ENDIF}
  begin
       with FOwner do
       begin
            for i:=0 to SomeFieldDefs.Count - 1 do
                with SomeFieldDefs[i] do
                begin
                     // Check if a varlength field (blobs and long strings f.ex.).
                     if (FFieldFlags[NbrFields] and kbmffIndirect)<>0 then
                     begin
                          // Check if to compress it.
                          if FPerformance=mtpfSmall then
                             FFieldFlags[NbrFields]:=FFieldFlags[NbrFields] or kbmffCompress;
                          FFieldOfs[NbrFields]:=FStartVarLength+FVarLengthCount*(SizeOf(PkbmVarLength)+1);
                          inc(FVarLengthCount);
                     end;
                     inc(NbrFields);

{$IFNDEF LEVEL3}
                     // Check if arraytype field. Adjust field counter.
                     if ChildDefs.Count > 0 then
                     begin
                          if DataType = ftArray then
                             for j:=1 to Size do EnumerateVarLengthFieldDefs(ChildDefs,NbrFields)
                          else
                              EnumerateVarLengthFieldDefs(ChildDefs,NbrFields);
                     end;
{$ENDIF}
                end;
       end;
  end;

var
   Temp:integer;
begin
     if FOwner.FieldDefs.Count<=0 then
        raise EMemTableError.Create(kbmVarReason2Err);

     // Calculate size of bookmark array in record.
     FBookmarkArraySize:=sizeof(TkbmBookmark)*FAttachMaxCount;

     // Calculate non blob field offsets into the record.
     FFixedRecordSize:=0;
     FFieldCount:=AFieldCount;
     Temp:=0;
     EnumerateFieldDefs(FOwner.FieldDefs,Temp);

     // Calculate some size variables.
     FStartCalculated:=FFixedRecordSize;
     FCalcRecordSize:=FOwner.CalcFieldsSize;
     FStartBookmarks:=FStartCalculated+FCalcRecordSize;
     FStartVarLength:=FStartBookmarks+FBookmarkArraySize;

     // Calculate number of var length fields and their place in the record.
     FVarLengthCount:=0;                  // Know of no var length fields in the definition yet.
     Temp:=0;
     EnumerateVarLengthFieldDefs(FOwner.FieldDefs,Temp);
     FVarLengthRecordSize:=FVarLengthCount * (SizeOf(PkbmVarLength)+1);

     // Calculate total sizes in different variations.
     FFixedRecordSize:=FStartVarLength;
     FDataRecordSize:=FFixedRecordSize+FVarLengthRecordSize;
     FTotalRecordSize:=sizeof(TkbmRecord)+FDataRecordSize;

     FIsDataModified:=False;
     ClearModifiedFlags;
end;

function TkbmCommon.IsAnyTableActive:boolean;
var
   i:integer;
begin
     Result:=false;
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
        begin
             if (FAttachedTables.Items[i]<>nil) and (TkbmCustomMemTable(FAttachedTables.Items[i]).Active) then
             begin
                  Result:=true;
                  exit;
             end;
        end;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.CloseTables(Caller:TkbmCustomMemTable);
var
   i:integer;
begin
     Lock;
     try
        for i:=FAttachedTables.count-1 downto 0 do
            if (FAttachedTables.Items[i]<>nil) and (Caller<>TkbmCustomMemTable(FAttachedTables.Items[i])) then
               with TkbmCustomMemTable(FAttachedTables.Items[i]) do Close;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.RefreshTables(Caller:TkbmCustomMemTable);
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.count-1 do
            if (FAttachedTables.Items[i]<>nil) and (Caller<>TkbmCustomMemTable(FAttachedTables.Items[i])) then
               with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                    if Active and (State in [dsBrowse]) then Refresh;
     finally
            Unlock;
     end;
end;

procedure TkbmCommon.ResyncTables;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then Resync([]);
     finally
        UnLock;
     end;
end;

procedure TkbmCommon.EmptyTables;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then InternalEmptyTable;
        _InternalEmpty;
     finally
        UnLock;
     end;
end;

procedure TkbmCommon.RebuildIndexes;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then Indexes.ReBuildAll;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.MarkIndexesDirty;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then Indexes.MarkAllDirty;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.ClearIndexes;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then
                        Indexes.EmptyAll;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.UpdateIndexes;
var
   i:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
            if (FAttachedTables.Items[i]<>nil) then
                with TkbmCustomMemTable(FAttachedTables.Items[i]) do
                     if Active then UpdateIndexes;
     finally
        Unlock;
     end;
end;

procedure TkbmCommon.ReflectToIndexes(const Caller:TkbmCustomMemTable; const How:TkbmIndexUpdateHow; const OldRecord,NewRecord:PkbmRecord; const RecordPos:integer; const DontVersion:boolean);
var
   i:integer;
   mt:TkbmCustomMemTable;
   rp:integer;
begin
     Lock;
     try
        for i:=0 to FAttachedTables.Count-1 do
        begin
             mt:=TkbmCustomMemTable(FAttachedTables.Items[i]);
             if mt=nil then continue;
             if mt<>Caller then rp:=-1
             else rp:=RecordPos;
             if mt.Active then
                mt.Indexes.ReflectToIndexes(How,OldRecord,NewRecord,rp,DontVersion);
        end;
     finally
        Unlock;
     end;
end;

// -----------------------------------------------------------------------------------
// TkbmIndex
// -----------------------------------------------------------------------------------
constructor TkbmIndex.Create(Name:string;DataSet:TkbmCustomMemtable; Fields:string; Options:TkbmMemTableCompareOptions; IndexType:TkbmIndexType; Internal:boolean);
begin
     inherited Create;

     FName:=Name;
     FIndexFields:=Fields;
     FDataSet:=DataSet;
     FType:=IndexType;
     FInternal:=Internal;
     FRowOrder:=false;
     FIsView:=false;
     FEnabled:=true;
{$IFDEF LEVEL5}
     FFilterParser:=nil;
{$ENDIF}
     FFilterFunc:=nil;
     FOrdered:=DataSet.FCommon.RecordCount<=0;
     FUpdateStatus:=[usInserted,usModified,usUnmodified];

     FReferences:=TkbmList.Create;

     // Build list of fields in index, and check them for validity.
     FIndexFieldList:=TkbmFieldList.create;
     FDataSet.BuildFieldList(FDataSet,FIndexFieldList,FIndexFields);

     FIndexOptions:=Options;
     if (mtcoDescending in Options) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoDescending,FIndexFields);
     if (mtcoCaseInsensitive in Options) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoCaseInsensitive,FIndexFields);
     if (mtcoPartialKey in Options) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoPartial,FIndexFields);
     if (mtcoIgnoreNullKey in Options) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoIgnoreNull,FIndexFields);
     if (mtcoIgnoreLocale in Options) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoIgnoreLocale,FIndexFields);
end;

{$IFDEF LEVEL5}
constructor TkbmIndex.Create(IndexDef:TIndexDef;DataSet:TkbmCustomMemtable);
{$ELSE}
constructor TkbmIndex.CreateByIndexDef(IndexDef:TIndexDef;DataSet:TkbmCustomMemtable);
{$ENDIF}
begin
     inherited Create;

     FName:=IndexDef.Name;
     FIndexFields:=IndexDef.Fields;
     FDataSet:=DataSet;
     FType:=mtitSorted;
     FInternal:=false;
     FRowOrder:=false;
     FIsView:=false;
     FEnabled:=true;
{$IFDEF LEVEL5}
     FFilterParser:=nil;
{$ENDIF}
     FFilterFunc:=nil;
     FOrdered:=DataSet.FCommon.RecordCount<=0;
     FUpdateStatus:=[usInserted,usModified,usUnmodified];

     FReferences:=TkbmList.Create;

     // Build list of fields in index, and check them for validity.
     FIndexFieldList:=TkbmFieldList.create;
     FDataSet.BuildFieldList(FDataSet,FIndexFieldList,IndexDef.Fields);

     FIndexOptions:=IndexOptions2CompareOptions(IndexDef.Options);

     if (mtcoDescending in FIndexOptions) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoDescending,IndexDef.DescFields);
     if (mtcoCaseInsensitive in FIndexOptions) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoCaseInsensitive,IndexDef.CaseInsFields);
     if (mtcoPartialKey in FIndexOptions) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoPartial,FIndexFields);
     if (mtcoIgnoreNullKey in FIndexOptions) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoIgnoreNull,FIndexFields);
     if (mtcoIgnoreLocale in FIndexOptions) then FDataSet.SetFieldListOptions(FIndexFieldList,mtifoIgnoreLocale,FIndexFields);
end;

destructor TkbmIndex.Destroy;
begin
     Clear;
{$IFDEF LEVEL5}
     if FFilterParser<>nil then
     begin
          FFilterParser.Free;
          FFilterParser:=nil;
     end;
{$ENDIF}
     FReferences.free;
     FIndexFieldList.free;
     inherited;
end;

function TkbmIndex.Filter(const ARecord:PkbmRecord):boolean;
var
   OldOverride:PkbmRecord;
begin
     if not (IsFiltered or Assigned(FFilterFunc) or Assigned(FDataSet.OnFilterIndex){$IFDEF LEVEL5} or Assigned(FFilterParser){$ENDIF})then
     begin
          Result:=true;
          exit;
     end;

     OldOverride:=FDataSet.FOverrideActiveRecordBuffer;
     try
        FDataSet.FOverrideActiveRecordBuffer:=ARecord;

        // Call filtering function if defined.
        if Assigned(FFilterFunc) then
        begin
             FFilterFunc(FDataSet,self,Result);
             if not Result then exit;
        end;

        // Call users own filtering if specified.
        if Assigned(FDataSet.OnFilterIndex) then
        begin
             FDataSet.OnFilterIndex(FDataSet,self,Result);
             if not Result then exit;
        end;

{$IFDEF LEVEL5}
        // Check if filterstring active.
        if Assigned(FFilterParser) then
        begin
             Result:=FDataSet.FilterExpression(ARecord,FFilterParser);
             if not Result then exit;
        end;
{$ENDIF}
     finally
        FDataSet.FOverrideActiveRecordBuffer:=OldOverride;
     end;
end;

procedure TkbmIndex.SetEnabled(AValue:boolean);
begin
     FEnabled:=AValue;
     if (FEnabled) and (not FOrdered) then Rebuild;
end;

// Compare two arbitrary records for sort.
function TkbmIndex.CompareRecords(const AFieldList:TkbmFieldList; const KeyRecord,ARecord:PkbmRecord; const SortCompare,Partial:boolean): Integer;
const
     RetCodes: array[Boolean, Boolean] of ShortInt = ((2,-1),(1,0));
begin
     with FDataSet do
     begin
          // Compare record contents.
          Result:=FCommon._InternalCompareRecords(AFieldList,-1,KeyRecord,ARecord,false,Partial,chBreakNE);

          // Couldnt compare them according to fieldcontents, will now compare according to recnum.
          if (Result=0) and SortCompare then
          begin
               Result:=RetCodes[KeyRecord^.RecordNo>=0,ARecord^.RecordNo>=0];
               if Result=2 then
                  Result:=KeyRecord.RecordID - ARecord.RecordID;

               // If descending sort on first field, invert result.
               if (mtifoDescending in AFieldList.Options[0]) then Result:=-Result;
          end;
     end;
end;

// Binary search routine on Record ID index.
// Non-recursive function.
function TkbmIndex.BinarySearchRecordID(FirstNo,LastNo:integer; const RecordID:integer; const Desc:boolean; var Index:integer):integer;
var
   Mid:integer;
   pRec:PkbmRecord;
begin
     Index:=-1;

     while FirstNo<=LastNo do
     begin
          // Look in the center of the interval.
          Mid:=(LastNo+FirstNo+1) div 2;
          pRec:=PkbmRecord(FReferences.Items[Mid]);

          // Compare records.
          Result:=RecordID - pRec^.RecordID;

          // If found exactly.
          if Result=0 then
          begin
               Index:=Mid;
               exit;
          end;

          if Desc then Result:=-Result;

          // Not matching, dig deeper.

          // If the key is smaller than the middle record, look in the lower half segment.
          if Result<0 then
             LastNo:=Mid-1
          else
              FirstNo:=Mid+1;
     end;
     Result:=0;
end;

// Enhanced non recursive binary search.
function TkbmIndex.BinarySearch(FieldList:TkbmFieldList; FirstNo,LastNo:integer; const KeyRecord:PkbmRecord; const First,Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
var
   Mid:integer;
   PRec:PkbmRecord;

   procedure DoRespectFilter(ALimit:integer);
   var
      b:boolean;
   begin
        if (FirstNo<0) or (not RespectFilter) or (not FDataset.IsFiltered) or (FDataset.FilterRecord(FReferences.Items[FirstNo],false)) then exit;

        inc(FirstNo);
        while (FirstNo<=ALimit) do
        begin
             Result:=CompareRecords(FieldList,KeyRecord,PkbmRecord(FReferences.Items[FirstNo]),false,Nearest);
             b:=FDataset.FilterRecord(PkbmRecord(FReferences.Items[FirstNo]),false);

             // Check if acceptable record.
             if (b) and ((Result=0) or ((Nearest) and (Result<0))) then exit;

             // Look at next record.
             inc(FirstNo);
        end;
        Found:=false;
   end;
begin
     Result:=0;
     Found:=false;
     if FieldList=nil then FieldList:=FIndexFieldList;
     while FirstNo<=LastNo do
     begin
          Mid:=(FirstNo+LastNo) div 2;
//OutputDebugString(Pchar('Mid='+inttostr(Mid)));
          pRec:=PkbmRecord(FReferences.Items[Mid]);
          Result:=CompareRecords(FieldList,KeyRecord,pRec,false,false);
          if Result<0 then
             LastNo:=Mid-1
          else if Result>0 then
             FirstNo:=Mid+1
          else
          begin
               // Found record, now either backtrack or forward track.
               if First then
               begin
                    Dec(Mid);
                    while Mid>=0 do
                    begin
                         pRec:=PkbmRecord(FReferences.Items[Mid]);
                         Result:=CompareRecords(FieldList,KeyRecord,pRec,false,Nearest);
                         if Result<>0 then
                         begin
                              FirstNo:=Mid+1;
                              break;
                         end;
                         dec(Mid);
                    end;
               end

               else
               begin
                    inc(Mid);
                    while Mid<LastNo do
                    begin
                         pRec:=PkbmRecord(FReferences.Items[Mid]);
                         Result:=CompareRecords(FieldList,KeyRecord,pRec,false,Nearest);
                         if Result<>0 then
                         begin
                              FirstNo:=Mid-1;
                              break;
                         end;
                         inc(Mid);
                    end;
               end;

               // Finished searching.
               Result:=0;
               Found:=true;
               break;
          end;
     end;

     if FDataset.IsFiltered and (FirstNo>=0) and (FirstNo<FReferences.Count) then
        DoRespectFilter(LastNo);

     Index:=FirstNo;
end;

// Sequential search.
function TkbmIndex.SequentialSearch(FieldList:TkbmFieldList; const FirstNo,LastNo:integer; const KeyRecord:PkbmRecord; const Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
var
   i:integer;
   pRec:PkbmRecord;
//   desc:boolean;
begin
     // Loop for all records.
     if FieldList=nil then FieldList:=FIndexFieldList;
     Result:=0;
     Index:=-1;
     Found:=false;
//     desc:=(FieldList.Values[0] and mtifoDescending)<>0;

     for i:=FirstNo to LastNo do
     begin
          // Check if to recalc before compare.
          pRec:=PkbmRecord(FReferences.Items[i]);
          with FDataSet do
          begin
               // Call progress function.
               if (i mod 100) = 0 then
                 FDataSet.Progress(trunc((i-FirstNo)/(LastNo-FirstNo+1)*100),mtpcSearch);

               if FRecalcOnIndex then
               begin
                    // Fill calc fields part of buffer
                    ClearCalcFields(PChar(pRec));
                    GetCalcFields(PChar(pRec));
               end;
          end;

          // Check key record equal to record.
          Result:=CompareRecords(FieldList,KeyRecord,pRec,false,Nearest);

          // Check if found match but filtered.
          if (Result=0) and FDataset.IsFiltered and RespectFilter then
          begin
               if not FDataset.FilterRecord(pRec,false) then continue;
          end;

          // Check if nearest or match.
          if (Result=0) or (Nearest and (Result<0)) then
          begin
               Index:=i;
               Found:=true;
               exit;
          end;
     end;
     Index:=LastNo+1;
end;

// Sequential search for record ID.
function TkbmIndex.SequentialSearchRecordID(const FirstNo,LastNo:integer; const RecordID:integer; var Index:integer):integer;
var
   i:integer;
   pRec:PkbmRecord;
begin
     // Loop for all records.
     Result:=0;
     Index:=-1;
     for i:=FirstNo to LastNo do
     begin
          // Call progress function.
          if (i mod 100) = 0 then
            FDataSet.Progress(trunc((i-FirstNo)/(LastNo-FirstNo+1)*100),mtpcSearch);

          pRec:=PkbmRecord(FReferences.Items[i]);
          Result:=RecordID - pRec^.RecordID;

          if (Result=0) then
          begin
               Index:=i;
               exit;
          end;
     end;
end;

// Search.
// Aut. choose between indexed seq. search and indexed binary search.
function TkbmIndex.Search(FieldList:TkbmFieldList; KeyRecord:PkbmRecord; Nearest,RespectFilter:boolean; var Index:integer; var Found:boolean):integer;
var
   n:integer;
begin
     Index:=-1;

     // Lock the record list for our use, to make sure nobody alters it.
     FDataSet.Progress(0,mtpcSearch);
     FDataSet.FState:=mtstSearch;
     FDataSet.FCommon.Lock;
     try
        // Utilize best search method.
        n:=FReferences.Count;
        if n<=0 then
           Result:=0
        else if FOrdered and (not FRowOrder) and (n>20) then
            Result:=BinarySearch(FieldList,0,n-1,KeyRecord,true,Nearest,RespectFilter,Index,Found)
        else
           Result:=SequentialSearch(FieldList,0,n-1,KeyRecord,Nearest,RespectFilter,Index,Found);
     finally
        FDataSet.FCommon.Unlock;
        FDataSet.Progress(100,mtpcSearch);
        FDataSet.FState:=mtstBrowse;
     end;
end;

// Search for specific record in index.
function TkbmIndex.SearchRecord(KeyRecord:PkbmRecord; var Index:integer; RespectFilter:boolean):integer;
var
   First,Last:integer;
   i:integer;
   Found:boolean;
begin
     Index:=-1;
     Result:=0;

     // Lock the record list for our use, to make sure nobody alters it.
     FDataSet.FCommon.Lock;
     FDataSet.Progress(0,mtpcSearch);
     try
        // Check if anything to search.
        if (FReferences.count>0) then
        begin
             // Assume whole range.
             First:=0;
             Last:=FReferences.count-1;

             // Try to minimize the sequential scan for record.
             if FOrdered and (FReferences.Count>5) then
             begin
                  i:=-1;
                  if FRowOrder then
                  begin
                       SearchRecordID(KeyRecord^.RecordID,Index);
                       if Index>=0 then exit;
                  end
                  else
                     BinarySearch(nil,0,FReferences.Count-1,KeyRecord,true,false,RespectFilter,i,Found);
                  if Found and (i>=0) then First:=i;
             end;

             // Sequential scan for correct record id from that point.
             SequentialSearchRecordID(First,Last,KeyRecord^.RecordID,Index);
        end;
     finally
        FDataSet.FCommon.Unlock;
     end;
end;

// Search for specific record ID in row order index only.
function TkbmIndex.SearchRecordID(RecordID:integer; var Index:integer):integer;
begin
     // Try to look for it by binary search.
     // If records are inserted here and there in the index, they will not be sorted
     // as the roworderindex indicates the order the user has put the records in
     // using append and insert. But as a good guess, there should be a good chance
     // of finding a record by a binary search. If it wasnt found, we will try again
     // using a sequential search to be on the safe side.
     Index:=-1;
     Result:=0; // To fix bogus warning from compiler.

     // Lock the record list for our use, to make sure nobody alters it.
     FDataSet.FCommon.Lock;
     try
        if FOrdered and FRowOrder then
        begin
             Result:=BinarySearchRecordID(0,FReferences.Count-1,RecordID,false,Index);
             if Index<0 then
                Result:=BinarySearchRecordID(0,FReferences.Count-1,RecordID,true,Index);
        end;

        if Index<0 then
            Result:=SequentialSearchRecordID(0,FReferences.Count-1,RecordID,Index);
     finally
        FDataSet.FCommon.Unlock;
     end;
end;

// Routines used by FastQuicksort.
procedure TkbmIndex.InternalSwap(const I,J:integer);
var
   t:PkbmRecord;
begin
     t:=FReferences[I];
     FReferences[I]:=FReferences[J];
     FReferences[J]:=t;
end;

{$IFDEF USE_FAST_QUICKSORT}
procedure TkbmIndex.InternalFastQuickSort(const L,R:Integer);
var
   I,J:integer;
   P:PkbmRecord;
begin
     if ((R-L)>4) then
//     if ((R-L)>0) then
     begin
          I:=(R+L) div 2;
          if CompareRecords(FIndexFieldList,PkbmRecord(FReferences[L]),PkbmRecord(FReferences[I]),true,false)>0 then
           InternalSwap(L,I);
          if CompareRecords(FIndexFieldList,PkbmRecord(FReferences[L]),PkbmRecord(FReferences[R]),true,false)>0 then
           InternalSwap(L,R);
          if CompareRecords(FIndexFieldList,PkbmRecord(FReferences[I]),PkbmRecord(FReferences[R]),true,false)>0 then
           InternalSwap(I,R);

          J:=R-1;
          InternalSwap(I,J);
          I:=L;
          P:=PkbmRecord(FReferences[J]);
          while true do
          begin
               Inc(I);
               Dec(J);
               while CompareRecords(FIndexFieldList,PkbmRecord(FReferences[I]),P,true,false) < 0 do Inc(I);
               while CompareRecords(FIndexFieldList,PkbmRecord(FReferences[J]),P,true,false) > 0 do Dec(J);
               if (J<I) then break;
               InternalSwap(I,J);
          end;
          InternalSwap(I,R-1);
          InternalFastQuickSort(L,J);
          InternalFastQuickSort(I+1,R);
     end;
end;

procedure TkbmIndex.InternalInsertionSort(const Lo,Hi:integer);
var
   I,J:integer;
   P:PkbmRecord;
begin
     for I:=Lo+1 to Hi do
     begin
          P:=PkbmRecord(FReferences.Items[I]);
          J:=I;
          while ((J>Lo) and (CompareRecords(FIndexFieldList,PkbmRecord(FReferences[J-1]),P,true,false)>0)) do
          begin
               FReferences[J]:=FReferences[J-1];
               dec(J);
          end;
          FReferences[J]:=P;
     end;
end;

// Sort the record refences using the Fast Quicksort algorithm.
procedure TkbmIndex.FastQuickSort(const L,R:Integer);
begin
     InternalFastQuickSort(L,R);
     InternalInsertionSort(L,R);
     FOrdered:=true;
end;
{$ELSE}

// Sort the record refences using the Quicksort algorithm.
procedure TkbmIndex.QuickSort(L,R:Integer);
var
   I,J:Integer;
   P:PKbmRecord;
begin
     repeat
           I:=L;
           J:=R;
           P:=PkbmRecord(FReferences.Items[(L + R) shr 1]);
           repeat
                 while CompareRecords(FIndexFieldList,PkbmRecord(FReferences[I]),P,true,false) < 0 do Inc(I);
                 while CompareRecords(FIndexFieldList,PkbmRecord(FReferences[J]),P,true,false) > 0 do Dec(J);
                 if I <= J then
                 begin
                      InternalSwap(I,J);
                      Inc(I);
                      Dec(J);
                 end;
           until I>J;
           if L<J then QuickSort(L,J);
           L:=I;
    until I>=R;
    FOrdered:=true;
end;
{$ENDIF}

procedure TkbmIndex.Clear;
begin
     FReferences.Clear;
     FOrdered:=false;
end;

function TkbmIndex.FindRecordNumber(const RecordBuffer:PChar):integer; {$IFDEF DOTNET}unsafe;{$ENDIF}
var
   i:integer;
begin
     for i:=0 to FReferences.Count-1 do
         if PChar(FReferences[i])=RecordBuffer then
         begin
              Result:=i;
              exit;
         end;
     Result:=-1;
end;

procedure TkbmIndex.LoadAll;
var
   i:integer;
   p:PkbmRecord;
begin
     Clear;
     FOrdered:=false;

     FDataSet.FCommon.Lock;
     try
        // Set capacity for references and recnolist.
        if not IsFiltered then
           FReferences.Capacity:=FDataSet.FCommon.RecordCount
        else
            FReferences.Capacity:=100;

        // Add the records.
        with FDataSet,FCommon do
        begin
             for i:=0 to FRecords.Count-1 do
             begin
                  p:=PkbmRecord(FRecords.Items[i]);
                  if p<>nil then
                  begin
                       if not (p^.UpdateStatus in FUpdateStatus) or
                          ((p^.UpdateStatus=usDeleted) and (not FDataSet.EnableVersioning)) then continue;
                       if not self.Filter(p) then continue;
                       FReferences.Add(p);
                  end;
             end;
        end;
     finally
        FDataSet.FCommon.Unlock;
     end;
end;

procedure TkbmIndex.ReSort;
var
   i:integer;
begin
     // If not sorted, dont bother to sort the index.
     if FType=mtitNonSorted then
     begin
          if IsRowOrder then FOrdered:=true;
          exit;
     end;

     // Lock the record list for our use, to make sure nobody alters it.
     FDataSet.Progress(0,mtpcSort);
     FDataSet.FState:=mtstSort;
     FDataSet.FCommon.Lock;
     try
        // Sort the index.
{$IFDEF USE_FAST_QUICKSORT}
        FastQuickSort(0,FReferences.Count-1);
{$ELSE}
        QuickSort(0,FReferences.Count-1);
{$ENDIF}

        // If unique index, look for duplicates.
        if mtcoUnique in FIndexOptions then
           for i:=1 to FReferences.Count-1 do
               if CompareRecords(FIndexFieldList,FReferences[i-1],FReferences[i],false,false)=0 then
                  raise EMemTableDupKey.Create(kbmDupIndex);
     finally
        FDataSet.FCommon.Unlock;
        FDataSet.Progress(100,mtpcSort);
        FDataSet.FState:=mtstBrowse;
     end;
end;

procedure TkbmIndex.Rebuild;
begin
     if FDataset.Active then
     begin
          if not FIsView then LoadAll;
          if FReferences.Count>0 then ReSort;
     end
     else
         FOrdered:=true;

     if (FDataSet.FCurIndex=self) and (FDataSet.FRecNo>=FReferences.Count) then
        FDataSet.FRecNo:=FReferences.Count-1;
end;

// -----------------------------------------------------------------------------------
// TkbmIndexes
// -----------------------------------------------------------------------------------
constructor TkbmIndexes.Create(ADataSet:TkbmCustomMemTable);
begin
     inherited Create;
     FIndexes:=TStringList.Create;
     FDataSet:=ADataSet;
end;

destructor TkbmIndexes.Destroy;
var
   i:integer;
begin
     for i:=0 to FIndexes.count-1 do
         TkbmList(FIndexes.Objects[i]).free;
     FIndexes.free;
     inherited;
end;

// Remove indexes.
procedure TkbmIndexes.Clear;
var
   i:integer;
   lIndex:TkbmIndex;
begin
     for i:=FIndexes.Count-1 downto 0 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);
          lIndex.Clear;
          if lIndex = FRowOrderIndex then continue;
          if lIndex = FDataSet.FCurIndex then FDataSet.FCurIndex:=FRowOrderIndex;
          if lIndex = FDataSet.FSortIndex then FDataSet.FSortIndex := nil;
          lIndex.free;
          FIndexes.delete(i);
     end;
end;

function TkbmIndexes.Count:integer;
begin
     Result:=FIndexes.Count;
end;

function TkbmIndexes.Get(const IndexName:string):TkbmIndex;
var
   i:integer;
   lIndex:TkbmIndex;
begin
     for i:=0 to FIndexes.Count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);
          if (UpperCase(lIndex.FName) = UpperCase(IndexName)) then
          begin
               Result:=lIndex;
               exit;
          end;
     end;
     Result:=nil;
end;

function TkbmIndexes.GetIndex(const Ordinal:integer):TkbmIndex;
begin
     Result:=nil;
     if (Ordinal<0) or (Ordinal>=FIndexes.Count) then exit;
     Result:=TkbmIndex(FIndexes.Objects[Ordinal]);
end;

// Lookup first index on specified fieldnames.
function TkbmIndexes.GetByFieldNames(FieldNames:string):TkbmIndex;
var
   i:integer;
   lIndex:TkbmIndex;
begin
     Result:=nil;
     FieldNames:=UpperCase(FieldNames);
     for i:=0 to FIndexes.count-1 do
     begin
         lIndex:=TkbmIndex(FIndexes.Objects[i]);
         if (UpperCase(lIndex.FIndexFields) = FieldNames) then
         begin
              Result:=lIndex;
              break;
         end;
     end;
end;

procedure TkbmIndexes.AddIndex(const Index:TkbmIndex);
begin
     Index.FIndexOfs:=FIndexes.count;
     FIndexes.AddObject(Index.FName,Index);
end;

procedure TkbmIndexes.Add(const IndexDef:TIndexDef);
var
   lIndex:TkbmIndex;
begin
     if (IndexDef.Fields='') then
        raise EMemTableError.Create(kbmMissingNames);

{$IFDEF LEVEL5}
     lIndex:=TkbmIndex.Create(IndexDef,FDataSet);
{$ELSE}
     lIndex:=TkbmIndex.CreateByIndexDef(IndexDef,FDataSet);
{$ENDIF}
     AddIndex(lIndex);
end;

procedure TkbmIndexes.DeleteIndex(const Index:TkbmIndex);
var
   iIndex:integer;
   lIndex:TkbmIndex;
begin
     // Dont allow deletion of roworder index.
     if Index=FRowOrderIndex then exit;
     if Index=Index.FDataSet.FCurIndex then Index.FDataSet.FCurIndex:=FRowOrderIndex;

     for iIndex:=0 to FIndexes.count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[iIndex]);
          if lIndex=Index then
          begin
               FIndexes.delete(iIndex);
               break;
          end;
     end;

     // Renumber rest indexes.
     while (iIndex<FIndexes.count-1) do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[iIndex]);
          dec(lIndex.FIndexOfs);
          inc(iIndex);
     end;
end;

procedure TkbmIndexes.Delete(const IndexName:string);
var
   lIndex:TkbmIndex;
begin
     lIndex:=Get(IndexName);

     // Dont allow deletion of roworder index.
     if lIndex=FRowOrderIndex then exit;
     if lIndex=FDataSet.FCurIndex then FDataSet.FCurIndex:=FRowOrderIndex;
     DeleteIndex(lIndex);
end;

procedure TkbmIndexes.Empty(const IndexName:string);
var
   lIndex:TkbmIndex;
begin
     // Get reference to index reference list.
     lIndex:=Get(IndexName);
     lIndex.Clear;
end;

procedure TkbmIndexes.EmptyAll;
var
   i:integer;
   lIndex:TkbmIndex;
begin
     for i:=0 to FIndexes.Count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);
          lIndex.Clear;
     end;
end;

procedure TkbmIndexes.ReBuild(const IndexName:string);
var
   lIndex:TkbmIndex;
begin
     // Get reference to index reference list.
     if not FDataSet.Active then exit;
     lIndex:=Get(IndexName);
     lIndex.Rebuild;
end;

procedure TkbmIndexes.ReBuildAll;
var
   i:integer;
   lIndex:TkbmIndex;
begin
     for i:=0 to FIndexes.Count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);
          lIndex.Rebuild;
     end;
end;

procedure TkbmIndexes.MarkAllDirty;
var
   iIndex:integer;
   lIndex:TkbmIndex;
begin
     for iIndex:=0 to FIndexes.Count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[iIndex]);
          lIndex.FOrdered:=false;
     end;
end;

// Search for keyrecord on specified fields.
// Aut. selects the optimal search method depending if an index is available.
// CurIndex is a reference to the current index, that is the one the Index value will refer
// to as a result.
function TkbmIndexes.Search(const FieldList:TkbmFieldList; const KeyRecord:PkbmRecord; const Nearest,RespectFilter,AutoAddIdx:boolean; var Index:integer; var Found:boolean):integer;
var
   i:integer;
   s:string;
   pRec:PkbmRecord;
   idxFound:boolean;
   ix:TkbmIndex;
   fl:TkbmFieldList;
begin
     // Check for index to search on.
     Index:=-1;
     Found:=false;
     Result:=0;

     // Create merger of the options of the given and the index field list and use it.
     fl:=TkbmFieldList.Create;
     try
        if FDataSet.FCurIndex.FOrdered and (FDataSet.FCurIndex.FReferences.Count>20) then
        begin
             // Look for an index which can be used.
             idxFound:=false;
             for i:=FIndexes.Count-1 downto 0 do
                 if TkbmIndex(FIndexes.Objects[i]).FOrdered and
                    FDataSet.IsFieldListsBegin(TkbmIndex(FIndexes.Objects[i]).FIndexFieldList,FieldList) then
                 begin
                      idxFound:=true;
                      break;
                 end;

             // If no index found, optionally add one.
             if not idxFound and AutoAddIdx then
             begin
                  // Build new string of fieldnames for new index.
                  s:=FieldList.Fields[0].FieldName;
                  for i:=1 to FieldList.Count-1 do
                      s:=s+';'+FieldList.Fields[i].FieldName;

                  // Add new index.
                  FDataSet.AddIndex(kbmAutoIndex+s,s,[ixCaseInsensitive]);
                  idxFound:=true;
                  i:=FIndexes.Count-1;
             end;

             // If found an index to search on.
             if idxFound then
             begin
                  ix:=TkbmIndex(FIndexes.Objects[i]);

                  // Merge two fieldlists options.
                  FieldList.AssignTo(fl);
                  ix.FIndexFieldList.MergeOptionsTo(fl);

                  //ix.FIndexFieldList.AssignTo(fl);
                  //FieldList.MergeOptionsTo(fl);

                  // Search.
                  Result:=ix.Search(fl,KeyRecord,Nearest,RespectFilter,Index,Found);

                  // Check if found record.
                  if ((Result=0) or (Nearest and (Result<0))) and
                     (Index>=0) and (Index<ix.FReferences.Count) then
                  begin
                       // Check if it wasnt current index that was searched. Then have to research on current.
                       if FDataSet.FCurIndex<>ix then
                       begin
                            // Do 2nd search.
                            Result:=FDataSet.FCurIndex.SearchRecord(ix.References.Items[Index],Index,RespectFilter);
                            if Index>=ix.FReferences.Count then
                               Found:=false;
                       end;
                  end
                  else
                      Found:=false;
                  exit;
             end;
        end;

        // No compatible indexes found, do a sequential search on current index.
        with FDataSet.FCurIndex do
        begin
             // Use given fieldlist as base instead of index field list. Then merge indexfieldlist options in.
             FieldList.AssignTo(fl);
             FIndexFieldList.MergeOptionsTo(fl);

             i:=0;
             while i<FReferences.Count do
             begin
                  // Check if to recalc before compare.
                  pRec:=PkbmRecord(FReferences.Items[i]);
                  with FDataSet do
                  begin
                       if FRecalcOnIndex then
                       begin
                            //fill calc fields part of buffer
                            ClearCalcFields(PChar(pRec));
                            GetCalcFields(PChar(pRec));
                       end;
                  end;

                  // Check key record equal to record.
                  Result:=CompareRecords(fl,KeyRecord,pRec,false,Nearest);

                  // Check if found match but filtered.
                  if (Result=0) and FDataset.IsFiltered and RespectFilter then
                  begin
                       if not FDataset.FilterRecord(pRec,false) then
                       begin
                            inc(i);
                            continue;
                       end;
                  end;

                  // Check if nearest or match.
                  if (Result=0) or (Nearest and (Result<0)) then
                  begin
                       Index:=i;
                       Found:=true;
                       exit;
                  end;

                  inc(i);
             end;
        end;
     finally
        fl.Free;
     end;
end;

// Check a record for acceptance regarding indexdefinitions.
procedure TkbmIndexes.CheckRecordUniqueness(const ARecord,ActualRecord:PkbmRecord);
var
   i:integer;
   iResult:integer;
   lIndex:TkbmIndex;
   Found:boolean;
begin
     // If indexes not enabled, dont make uniqueness test.
     if not FDataSet.FEnableIndexes then exit;

     // Check all indexes for uniqueness.
     for i:=0 to FIndexes.Count-1 do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);
          with lIndex do
          begin
               if not FEnabled then continue;
{$IFNDEF LEVEL3}
               if (mtcoNonMaintained in FIndexOptions) then continue;
{$ENDIF}

               // Check if unique index and duplicate key, complain.
               if (mtcoUnique in FIndexOptions)
                  and ((Search(nil,ARecord,false,false,iResult,Found)=0) and Found and (iResult>=0))
                  and (lIndex.FReferences[iResult] <> ActualRecord) then
                  raise EMemTableDupKey.Create(kbmDupIndex);
          end;
     end;
end;

// Call this during insert, append, edit or delete of record to update the index lists.
// OldRecord contains a reference to the actual 'physical' record.
// NewRecord points to a buffer which contains the new value soon to be copied into OldRecord. (Edit)
// NewRecord is nil on append or insert since OldRecord allready will contain values.
// RecordPos specifies current FRecNo.
// Returns pos in current index for operation.
procedure TkbmIndexes.ReflectToIndexes(const How:TkbmIndexUpdateHow; const OldRecord,NewRecord:PkbmRecord; const RecordPos:integer; const DontVersion:boolean);
var
   i,ni:integer;
   lIndex:TkbmIndex;
   IsRowOrderIndex,IsCurIndex,IsIndexesEnabled:boolean;
   iInsert,iDelete:integer;
   DoAppend:boolean;
   Found:boolean;
   n,m:integer;
begin
     // Loop through all indexes.
     ni:=FIndexes.Count-1;
     for i:=0 to ni do
     begin
          lIndex:=TkbmIndex(FIndexes.Objects[i]);

          IsRowOrderIndex:=(lIndex = FRowOrderIndex);
          IsCurIndex:=(lIndex = FDataSet.FCurIndex);
          IsIndexesEnabled:=FDataset.FEnableIndexes;

          with lIndex do
          begin
               // Check if to skip updating this index. Never skip if deleting on the current index.
               if {$IFNDEF LEVEL3}(mtcoNonMaintained in FIndexOptions) or {$ENDIF}
                  ((not (IsIndexesEnabled and lIndex.Enabled)) and ((How<>mtiuhDelete) or (not IsCurIndex))) then
               begin
                    // Roworder indexes will still be ordered during an edit with indexes disabled.
                    if (How<>mtiuhEdit) or (not IsRowOrder) then FOrdered:=false;
                    continue;
               end;
               FOrdered:=true;

               // Check how to update index.
               case How of
                    mtiuhEdit:
                       begin
                            // Is it the roworder index? Dont do anything since it wont change anything.
                            if IsRowOrderIndex then continue;

                            // Do not update indexes if key has not changed unless updatestatus filtering is enabled.
                            if (usModified in FUpdateStatus) and (lIndex.CompareRecords(lIndex.FIndexFieldList,OldRecord,NewRecord,false,false)=0) then
                            begin
                                 if IsCurIndex then FDataset.FReposRecNo:=NewRecord.RecordNo;
                                 continue;
                            end;

                            // Search the original position.
                            // Is it the current index, then use FRecNo, otherwise look for it.
                            if IsCurIndex and (RecordPos>=0) then
                               iDelete:=RecordPos
                            else
                            begin
                                 iDelete:=-1;
                                 SearchRecord(OldRecord,iDelete,false);
                            end;
                            // Check if didnt find original record in index, dont try to delete it.
                            // Situation can occur if several tables are attached together and
                            // one of the tables have filtered indexes, but the other not.
                            // Then changing a value in the non filtered index on one table will
                            // result in a request to update the filtered index on the other table.
                            // And in that table, the record wont be found because it wasnt there in
                            // the first place because of the filter.
                            if iDelete>=0 then
                               FReferences.Delete(iDelete);

                            // Check if filtering.
                            if FIsFiltered and (not Filter(NewRecord)) then continue;

                            // Check if modified not allowed by updatestatus filter.
                            if not (usModified in FUpdateStatus) then continue;

                            // If any references left, look for nearest insertion place.
                            iInsert:=-1;
                            Search(nil,NewRecord,true,false,iInsert,Found);

                            // If found insertion place, insert.
                            if iInsert>=0 then
                               // Insert the reference at new place.
                               FReferences.Insert(iInsert,OldRecord)
                            else
                               // Add reference to list.
                               iInsert:=FReferences.Add(OldRecord);

                            if IsCurIndex then
                            begin
                                 FDataset.FReposRecNo:=iInsert;
                                 OldRecord^.RecordNo:=iInsert;
                            end;
                       end;

                    mtiuhInsert:
                       begin
                            // Check if filtering.
                            if FIsFiltered and (not Filter(NewRecord)) then continue;

                            // Check if inserted not allowed by updatestatus filter.
                            if not (usInserted in FUpdateStatus) then continue;

                            // Is it the roworder index? Is it the same as the one we are looking at?
                            if IsRowOrderIndex then
                            begin
                                 if IsCurIndex then
                                 begin
                                      if RecordPos<0 then
                                         DoAppend:=true
                                      else
                                      begin
                                           iInsert:=RecordPos-1;
                                           DoAppend:=false;
                                      end;
                                 end
                                 else
                                 begin
                                      iInsert:=-1;
                                      DoAppend:=true;
                                 end;
                            end
                            else
                            begin
                                 n:=FReferences.Count;
                                 if n>0 then
                                 begin
                                      iInsert:=-1;
                                      m:=Search(nil,NewRecord,true,false,iInsert,Found);
                                      DoAppend:=(m>0) and (iInsert>=n-1)
                                 end
                                 else
                                     DoAppend:=true;
                            end;

                            // Figure out if to append or to insert to index.
                            if DoAppend then
                            begin
                                 // Append reference to index.
                                 iInsert:=FReferences.Add(NewRecord);
                            end
                            else
                            begin
                                 // Insert reference.
                                 if iInsert<0 then iInsert:=0;
                                 FReferences.Insert(iInsert,NewRecord);
                            end;

                            if IsCurIndex then
                            begin
                                 FDataset.FReposRecNo:=iInsert;
                                 NewRecord^.RecordNo:=iInsert;
                            end;
                       end;

                    mtiuhDelete:
                       begin
                            // Check if to leave deleted record in index (only a point if versioning.
                            if (usDeleted in FUpdateStatus) and (FDataSet.EnableVersioning) and (not DontVersion) then
                            begin
                                 // Check if this index contained original record or not.
                                 // If it didnt, we have to insert it now.
                                 if not (OldRecord^.UpdateStatus in FUpdateStatus) then
                                 begin

                                      // Check record ok due to other filters.
                                      if (not FIsFiltered) or Filter(OldRecord) then
                                      begin
                                           // Figure out where to place record in index.
                                           n:=FReferences.Count;
                                           if n>0 then
                                           begin
                                                iInsert:=-1;
                                                m:=Search(nil,OldRecord,true,false,iInsert,Found);
                                                DoAppend:=(m>0) and (iInsert>=n-1)
                                           end
                                           else
                                               DoAppend:=true;

                                           // Figure out if to append or to insert to index.
                                           if DoAppend then
                                           begin
                                                // Append reference to index.
                                                iInsert:=FReferences.Add(OldRecord);
                                           end
                                           else
                                           begin
                                                // Insert reference.
                                                if iInsert<0 then iInsert:=0;
                                                FReferences.Insert(iInsert,OldRecord);
                                           end;

                                           if IsCurIndex then
                                           begin
                                                FDataset.FReposRecNo:=iInsert;
                                                OldRecord^.RecordNo:=iInsert;
                                           end;
                                      end;
                                 end;

                                 // Dont remove it from this index.
                                 continue;
                            end;

                            if FReferences.Count>0 then
                            begin
                                 iDelete:=-1;

                                 // Is it the roworder index?
                                 if IsRowOrderIndex then
                                    SearchRecordID(OldRecord^.RecordID,iDelete)
                                 else
                                     SearchRecord(OldRecord,iDelete,false);
                                 if iDelete>=0 then
                                    FReferences.Delete(iDelete);

                                 if IsCurIndex then FDataset.FReposRecNo:=iDelete;
                            end;
                       end;
               end;
          end;
     end;
end;

// -----------------------------------------------------------------------------------
// TkbmCustomMemTable
// -----------------------------------------------------------------------------------

constructor TkbmCustomMemTable.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);

     FTableID:=0;
     FCommon:=TkbmCommon.Create(self);

     // Now attach to the common tablestructure.
     FCommon.AttachTable(self);

     // Create indexlist.
     FIndexes:=TkbmIndexes.Create(self);

     // Add row order index to indexlist.
     with FIndexes do
     begin
          FRowOrderIndex:=TkbmIndex.Create(kbmRowOrderIndex,self,'',[],mtitNonSorted,true);
          FRowOrderIndex.FRowOrder:=true;
          AddIndex(FRowOrderIndex);
     end;

     // Default all load/save operations should load/save all records.
     FLoadLimit:=-1;
     FLoadCount:=-1;
     FLoadedCompletely:=false;
     FSaveLimit:=-1;
     FSaveCount:=-1;
     FSavedCompletely:=false;

     // Suppose standalone table.
     // If FAttachedTo points to another memtable, FRecords and FDeletedRecords will point
     // to the other tables FRecords and FDeletedRecords.
//     FAttachedChildren:=TThreadList.Create;
     FAttachedTo:=nil;
     FAttachedAutoRefresh:=true;

     FAutoReposition:=false;
{$IFNDEF LEVEL3}
     FDesignActivation:=true;
{$ENDIF}

     FRecNo:=-1;

     FPersistent:=false;
     FRecalcOnIndex:=false;
     FRecalcOnFetch:=true;
     FRangeIgnoreNullKeyValues:=true;

     FProgressFlags:=[mtpcSave,mtpcLoad,mtpcCopy];
     FState:=mtstBrowse;

     Inherited BeforeInsert:=_InternalBeforeInsert;

{$IFDEF LEVEL5}
     FFilterParser:=nil;
{$ENDIF}

     FIndexList:=TkbmFieldList.Create;
     FMasterIndexList:=TkbmFieldList.Create;
     FDetailIndexList:=TkbmFieldList.Create;
     FIndexDefs:=TIndexDefs.Create(Self);
     FSortIndex:=nil;
     FEnableIndexes:=true;
     FAutoAddIndexes:=false;

     FStoreDataOnForm:=false;
     FTempDataStorage:=nil;

     FAutoUpdateFieldVariables:=false;

     FMasterLink:=TMasterDataLink.Create(Self);
     FMasterLink.OnMasterChange:=MasterChanged;
     FMasterLink.OnMasterDisable:=MasterDisabled;
     FMasterLinkUsed:=true;
end;

destructor TkbmCustomMemTable.Destroy;
begin
     // Check if temporary data storage left over.
     if FTempDataStorage<>nil then FTempDataStorage.free;
     FTempDataStorage:=nil;

{$IFDEF LEVEL5}
     // Delete filterbuffers if assigned.
     FreeFilter(FFilterParser);
{$ENDIF}

     // Must be before deletion of records, otherwise it fails.
     inherited Destroy;

     // Delete allocated memory.
     FMasterLink.free;     FMasterLink:=nil;
     FIndexList.free;      FIndexList:=nil;
     FMasterIndexList.Free;FMasterIndexList:=nil;
     FDetailIndexList.Free;FDetailIndexList:=nil;

     // Dont delete shared data if attached to it.
     FCommon.DeAttachTable(Self);
     if FAttachedTo=nil then FCommon.free;

     // Free index definitions.
     FIndexDefs.free;      FIndexDefs:=nil;

     // Free indexreferences.
     FIndexes.free;
end;

procedure TkbmCustomMemTable.Lock;
begin
     FCommon.Lock;
     FCommon.FThreadProtected:=true;
end;

procedure TkbmCustomMemTable.Unlock;
begin
     FCommon.FThreadProtected:=false;
     FCommon.Unlock;
end;

procedure TkbmCustomMemTable.Loaded;
begin
{$IFNDEF LEVEL3}
     if not FDesignActivation then
        FInterceptActive:=true;
     try
        inherited;
     finally
        FInterceptActive:=false;
     end;
{$ELSE}
     inherited;
{$ENDIF}
end;

{$IFDEF LEVEL5}
procedure TkbmCustomMemTable.DataEvent(Event: TDataEvent; Info: Longint);
begin
     if FCommon.FThreadProtected then exit;
     inherited;
end;
{$ENDIF}

{$IFDEF LEVEL4}
procedure TkbmCustomMemTable.SetActive(Value:boolean);
begin
     if FInterceptActive and Value then exit;
     if (not Value) and (Persistent) then SavePersistent; 
     inherited SetActive(Value);
end;
{$ENDIF}

procedure TkbmCustomMemTable._InternalBeforeInsert(DataSet:TDataSet);
begin
     FInsertRecNo:=GetRecNo;
     if Assigned(FBeforeInsert) then FBeforeInsert(DataSet);
end;

procedure TkbmCustomMemTable.Progress(Pct:integer; Code:TkbmProgressCode);
begin
     if Assigned(FOnProgress) and (Code in FProgressFlags) then FOnProgress(self,Pct,Code);
end;

// Get current component version.
function TkbmCustomMemTable.GetVersion:string;
begin
     Result:=COMPONENT_VERSION;
end;

// Handle saving and loading static data from the form.
procedure TkbmCustomMemTable.DefineProperties(Filer:TFiler);
begin
     inherited;
     Filer.DefineBinaryProperty('Data', ReadData, WriteData, FStoreDataOnForm);
end;

procedure TkbmCustomMemTable.ReadData(Stream:TStream);
begin
     if FTempDataStorage<>nil then
     begin
          FTempDataStorage.free;
          FTempDataStorage:=nil;
     end;
     FTempDataStorage:=TMemoryStream.Create;
     FTempDataStorage.LoadFromStream(Stream);
end;

procedure TkbmCustomMemTable.WriteData(Stream:TStream);
begin
     if Active then
        InternalSaveToStreamViaFormat(Stream,FFormFormat);
end;

// Update the properties if some component we are dependent on is removed.
procedure TkbmCustomMemTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
     inherited Notification(AComponent, Operation);
     if Operation=opRemove then
     begin
          // Check if this table.
          if AComponent=self then
          begin
               // Close table.
//               if Active then SavePersistent;
               Close;
          end;
          if AComponent=FMasterLink.DataSource then FMasterLink.DataSource:=nil;
          if AComponent=FDeltaHandler then
          begin
               (AComponent as TkbmCustomDeltaHandler).FDataSet:=nil;
               FDeltaHandler:=nil;
          end;
          if AComponent=FAttachedTo then FAttachedTo:=nil;
          if AComponent=FDefaultFormat then FDefaultFormat:=nil;
          if AComponent=FCommaTextFormat then FCommaTextFormat:=nil;
          if AComponent=FPersistentFormat then FPersistentFormat:=nil;
          if AComponent=FFormFormat then FFormFormat:=nil;
          if AComponent=FAllDataFormat then FAllDataFormat:=nil;
     end;
end;

// Set minimum autoinc value.
procedure TkbmCustomMemTable.SetAutoIncMinValue(AValue:longint);
begin
     FCommon.AutoIncMin:=AValue;
end;

function TkbmCustomMemTable.GetAutoIncValue:longint;
begin
     Result:=FCommon.AutoIncMax;
end;

function TkbmCustomMemTable.GetAutoIncMin:longint;
begin
     Result:=FCommon.AutoIncMin;
end;

procedure TkbmCustomMemTable.SetLoadedCompletely(Value:boolean);
begin
     FLoadedCompletely:=Value;
end;

procedure TkbmCustomMemTable.SetTableState(AValue:TkbmState);
begin
     FState:=AValue;
end;

// Set performance.
procedure TkbmCustomMemTable.SetPerformance(AValue:TkbmPerformance);
begin
     FCommon.Performance:=AValue;
end;

function TkbmCustomMemTable.GetPerformance:TkbmPerformance;
begin
     Result:=FCommon.Performance;
end;

// Set versioning mode.
procedure TkbmCustomMemTable.SetVersioningMode(AValue:TkbmVersioningMode);
begin
     FCommon.VersioningMode:=AValue;
end;

function TkbmCustomMemTable.GetVersioningMode:TkbmVersioningMode;
begin
     Result:=FCommon.VersioningMode;
end;

// Set versioning enabled.
procedure TkbmCustomMemTable.SetEnableVersioning(AValue:boolean);
begin
     FCommon.EnableVersioning:=AValue;
end;

function TkbmCustomMemTable.GetEnableVersioning:boolean;
begin
     Result:=FCommon.EnableVersioning;
end;

procedure TkbmCustomMemTable.SetStandalone(AValue:boolean);
begin
     FCommon.Lock;
     try
        if AValue=FCommon.Standalone then exit;

        // Check if open.
        if Active then
           raise EMemTableError.Create(kbmTableMustBeClosed);

        // Check if myself attached.
        if FAttachedTo<>nil then
           raise EMemTableError.Create(kbmIsAttached);

        FCommon.Standalone:=AValue;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.GetStandalone:boolean;
begin
     Result:=FCommon.GetStandalone;
end;

procedure TkbmCustomMemTable.SetCapacity(AValue:longint);
begin
     FCommon.Capacity:=AValue;
end;

function TkbmCustomMemTable.GetCapacity:longint;
begin
     Result:=FCommon.Capacity;
end;

function TkbmCustomMemTable.GetAttachMaxCount:integer;
begin
     Result:=FCommon.AttachMaxCount;
end;

function TkbmCustomMemTable.GetAttachCount:integer;
begin
     Result:=FCommon.AttachCount;
end;

procedure TkbmCustomMemTable.SetAttachMaxCount(AValue:integer);
begin
     FCommon.AttachMaxCount:=AValue;
end;

function TkbmCustomMemTable.GetIsDataModified:boolean;
begin
     Result:=FCommon.IsDataModified;
end;

procedure TkbmCustomMemTable.SetIsDataModified(AValue:boolean);
begin
     FCommon.IsDataModified:=AValue;
end;

function TkbmCustomMemTable.GetTransactionLevel:integer;
begin
     Result:=FCommon.TransactionLevel;
end;

function TkbmCustomMemTable.GetIndexes:TkbmIndexes;
begin
     Result:=FIndexes;
end;

function TkbmCustomMemTable.GetDeletedRecordsCount:integer;
begin
     Result:=FCommon.GetDeletedRecordsCount;
end;

// Set transaction level.
procedure TkbmCustomMemTable.StartTransaction;
begin
     if not active then exit;
     if (not IsVersioning) or (VersioningMode <> mtvmAllSinceCheckPoint) then
        raise EMemTableError.Create(kbmTransactionVersioning);

     FCommon.IncTransactionLevel;
end;

// Rollback transaction.
procedure TkbmCustomMemTable.Rollback;
begin
     FCommon.Lock;
     try
        // Check if transaction started.
        if not active or (FCommon.FTransactionLevel<=0) then exit;
        UpdateCursorPos;
        FCommon.RollBack;
        FCommon.DecTransactionLevel;
        FCommon.RebuildIndexes;
        CursorPosChanged;
        Refresh;
     finally
        FCommon.Unlock;
     end;
end;

// Commit transaction.
procedure TkbmCustomMemTable.Commit;
begin
     FCommon.Lock;
     try
        // Check if transaction started.
        if not active or (FCommon.FTransactionLevel<=0) then exit;
        FCommon.Commit;
        FCommon.DecTransactionLevel;
        FCommon.RebuildIndexes;
        Refresh;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.Undo;
begin
     if not EnableVersioning then exit;
     FCommon.Undo(GetActiveRecord);
     Refresh;
end;

// Get number of versions of the current record.
function TkbmCustomMemTable.GetVersionCount:integer;
var
   pRec:PkbmRecord;
begin
     Result:=1;

     FCommon.Lock;
     try
        if not Active then raise EMemTableError.Create(kbmNoCurrentRecord);
        pRec:=GetActiveRecord;
        if pRec=nil then raise EMemTableError.Create(kbmNoCurrentRecord);

        while pRec^.PrevRecordVersion<>nil do
        begin
             inc(Result);
             pRec:=pRec^.PrevRecordVersion;
        end;
     finally
        FCommon.Unlock;
     end;
end;

// Get data of a specific version of a record.
function TkbmCustomMemTable.GetVersionFieldData(Field:TField; Version:integer):variant;
var
   pRec:PkbmRecord;
begin
     Result:=Null;
     FCommon.Lock;
     try
        if not Active then raise EMemTableError.Create(kbmNoCurrentRecord);
        pRec:=GetActiveRecord;
        if pRec=nil then raise EMemTableError.Create(kbmNoCurrentRecord);

        while (Version>0) and (pRec^.PrevRecordVersion<>nil) do
        begin
             dec(Version);
             pRec:=pRec^.PrevRecordVersion;
        end;

        FOverrideActiveRecordBuffer:=pRec;
        try
           Result:=Field.AsVariant;
        finally
           FOverrideActiveRecordBuffer:=nil;
        end;
     finally
        FCommon.Unlock;
     end;
end;

// Get TUpdateStatus of a specific version of a record.
function TkbmCustomMemTable.GetVersionStatus(Version:integer):TUpdateStatus;
var
   pRec:PkbmRecord;
begin
     Result:=usUnmodified;
     FCommon.Lock;
     try
        if not Active then raise EMemTableError.Create(kbmNoCurrentRecord);
        pRec:=GetActiveRecord;
        if pRec=nil then raise EMemTableError.Create(kbmNoCurrentRecord);

        while (Version>0) and (pRec^.PrevRecordVersion<>nil) do
        begin
             dec(Version);
             pRec:=pRec^.PrevRecordVersion;
        end;

        Result:=pRec^.UpdateStatus;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.SetVersionFieldData(Field:TField; AVersion:integer; AValue:variant):variant;
var
   pRec:PkbmRecord;
begin
     Result:=Null;
     FCommon.Lock;
     try
        if not Active then raise EMemTableError.Create(kbmNoCurrentRecord);
        pRec:=GetActiveRecord;
        if pRec=nil then raise EMemTableError.Create(kbmNoCurrentRecord);

        while (AVersion>0) and (pRec^.PrevRecordVersion<>nil) do
        begin
             dec(AVersion);
             pRec:=pRec^.PrevRecordVersion;
        end;

        FOverrideActiveRecordBuffer:=pRec;
        try
           Result:=Field.Value;
           Field.Value:=AValue;
        finally
           FOverrideActiveRecordBuffer:=nil;
        end;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.SetVersionStatus(AVersion:integer; AUpdateStatus:TUpdateStatus):TUpdateStatus;
var
   pRec:PkbmRecord;
begin
     Result:=usUnmodified;
     FCommon.Lock;
     try
        if not Active then raise EMemTableError.Create(kbmNoCurrentRecord);
        pRec:=GetActiveRecord;
        if pRec=nil then raise EMemTableError.Create(kbmNoCurrentRecord);

        while (AVersion>0) and (pRec^.PrevRecordVersion<>nil) do
        begin
             dec(AVersion);
             pRec:=pRec^.PrevRecordVersion;
        end;

        Result:=pRec^.UpdateStatus;
        pRec^.UpdateStatus:=AUpdateStatus;
     finally
        FCommon.Unlock;
     end;
end;

{$IFDEF LEVEL5}
function TkbmCustomMemTable.AddIndex(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet):TkbmIndex;
{$ELSE}
function TkbmCustomMemTable.AddIndex2(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet):TkbmIndex;
{$ENDIF}
var
   Index:TkbmIndex;
begin
     FIndexDefs.Add(Name,Fields,Options);
     FIndexDefs.Updated:=true;
     try
        Index:=TkbmIndex.Create(Name,self,Fields,IndexOptions2CompareOptions(Options),mtitSorted,false);
        Index.FUpdateStatus:=AUpdateStatus;
        Indexes.AddIndex(Index);
        UpdateIndexes;
        Result:=Index;
     except
        DeleteIndex(Name);
        UpdateIndexes;
        raise;
     end;
end;

{$IFDEF LEVEL5}
function TkbmCustomMemTable.AddFilteredIndex(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex {$ifdef LEVEL5} = nil{$endif}):TkbmIndex;
{$ELSE}
function TkbmCustomMemTable.AddFilteredIndex2(const Name, Fields: string; Options: TIndexOptions; AUpdateStatus:TUpdateStatusSet; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex):TkbmIndex;
{$ENDIF}
var
   Index:TkbmIndex;
begin
     FIndexDefs.Add(Name,Fields,Options);
     FIndexDefs.Updated:=true;
     try
        Index:=TkbmIndex.Create(Name,self,Fields,IndexOptions2CompareOptions(Options),mtitSorted,false);
        Index.FIsFiltered:=true;
        Index.FUpdateStatus:=AUpdateStatus;
{$IFDEF LEVEL5}
        if Filter<>'' then
           BuildFilter(Index.FFilterParser,Filter,FilterOptions)
        else
            Index.FFilterParser:=nil;
{$ENDIF}
        Index.FFilterFunc:=FilterFunc;
        Indexes.AddIndex(Index);
        UpdateIndexes;
        Result:=Index;
     except
        DeleteIndex(Name);
        UpdateIndexes;
        raise;
     end;
end;

function TkbmCustomMemTable.AddIndex(const Name, Fields: string; Options: TIndexOptions):TkbmIndex;
begin
{$IFDEF LEVEL5}
     Result:=AddIndex(Name,Fields,Options,[usInserted,usModified,usUnmodified]);
{$ELSE}
     Result:=AddIndex2(Name,Fields,Options,[usInserted,usModified,usUnmodified]);
{$ENDIF}
end;

function TkbmCustomMemTable.AddFilteredIndex(const Name, Fields: string; Options: TIndexOptions; Filter:string; FilterOptions:TFilterOptions; FilterFunc:TkbmOnFilterIndex {$ifdef LEVEL6} = nil{$endif}):TkbmIndex;
begin
{$IFDEF LEVEL5}
     Result:=AddFilteredIndex(Name,Fields,Options,[usInserted,usModified,usUnmodified],Filter,FilterOptions,FilterFunc);
{$ELSE}
     Result:=AddFilteredIndex2(Name,Fields,Options,[usInserted,usModified,usUnmodified],Filter,FilterOptions,FilterFunc);
{$ENDIF}
end;

procedure TkbmCustomMemTable.DeleteIndex(const Name: string);
var
   i:integer;
{$IFNDEF LEVEL5}
   id:TIndexDefs;
{$ENDIF}
begin
{$IFDEF LEVEL5}
     i:=FIndexDefs.IndexOf(Name);
     if i>=0 then
     begin
          FIndexDefs.Delete(i);
          UpdateIndexes;
     end;
{$ELSE}
{$IFDEF LEVEL3}
     // D3 missing delete method. Need to rebuild indexdefs.
     id:=TIndexDefs.Create(self);
     try
        id.Assign(FIndexDefs);
        FIndexDefs.Clear;
        for i:=0 to id.Count-1 do
            if id.Items[i].Name<>Name then
               FIndexDefs.Add(id.Items[i].Name,id.Items[i].Fields,id.Items[i].Options);
     finally
        id.free;
     end;
{$ELSE}
     // D4 missing delete method. Need to rebuild indexdefs.
     id:=TIndexDefs.Create(self);
     try
        id.Assign(FIndexDefs);
        FIndexDefs.Clear;
        for i:=0 to id.Count-1 do
            if id.Items[i].Name<>Name then
               FIndexDefs.AddIndexDef.Assign(id.Items[i]);
     finally
        id.free;
     end;
{$ENDIF}
{$ENDIF}
     FIndexDefs.Updated:=true;
end;

procedure TkbmCustomMemTable.SwitchToIndex(Index:TkbmIndex);
var
   id:integer;
begin
     if Index=FCurIndex then exit;

     id:=-1;
     if Active then
     begin
          CheckBrowseMode;
          id:=PkbmRecord(ActiveBuffer)^.RecordID;
     end;

//     CancelRange;
     if FCurIndex<>nil then UpdateCursorPos;

     if Index=nil then Index:=Indexes.FRowOrderIndex;

     // Check if index is updated. If not, update it.
     if not Index.FOrdered then Index.Rebuild;

     if Index.FInternal then
     begin
          FIndexFieldNames:='';
          FIndexName:='';
     end
     else
     begin
          FIndexFieldNames:=Index.FIndexFields;
          FIndexName:=Index.FName;
     end;
     FCurIndex:=Index;

     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     try
        // Repos recordno.
        if FRecNo>=FCurIndex.FReferences.Count then
           FRecNo:=FCurIndex.FReferences.Count-1;
        if Active and (FRecNo>=0) then
        begin
             FCurIndex.SearchRecordID(id,FRecNo);

             // Check if record accepted according to current filter. If not, seek first.
             if (FRecNo<0) or (FRecNo>=FCurIndex.FReferences.Count) or (not FilterRecord(FCurIndex.FReferences.Items[FRecNo],false)) then
                First;
        end;
//        Refresh;
        Resync([]);
     except
        SetState(dsInactive);
        CloseCursor;
        raise;
     end;
end;

procedure TkbmCustomMemTable.SetIndexFieldNames(FieldNames:string);
var
   lIndex:TkbmIndex;
begin
     if Active then
     begin
          if FieldNames='' then
             SwitchToIndex(nil)
          else
          begin
               lIndex:=Indexes.GetByFieldNames(FieldNames);
               if lIndex<>nil then SwitchToIndex(lIndex);
          end;
     end
     else
         FIndexFieldNames:=FieldNames;
end;

procedure TkbmCustomMemTable.SetIndexName(IndexName:string);
var
   lIndex:TkbmIndex;
begin
     if Active then
     begin
          if IndexName='' then
             SwitchToIndex(nil)
          else
          begin
               lIndex:=Indexes.Get(IndexName);
               if lIndex<>nil then SwitchToIndex(lIndex);
          end;
     end
     else
         FIndexName:=IndexName;
end;

procedure TkbmCustomMemTable.SetIndexDefs(Value:TIndexDefs);
begin
     FIndexDefs.assign(Value);
end;

procedure TkbmCustomMemTable.SetAutoUpdateFieldVariables(AValue:boolean);
begin
     if FAutoUpdateFieldVariables<>AValue then
     begin
          FAutoUpdateFieldVariables:=AValue;
          if Active then UpdateFieldVariables;
     end;
end;

procedure TkbmCustomMemTable.UpdateFieldVariables;
var
   i:integer;
begin
     if Assigned(owner)
        and (ComponentCount>0)
        and (Owner.ComponentCount>0)
        and not (csDesigning in ComponentState) then
     begin
          for i:=Pred(FieldCount) downto 0 do
              if not Assigned(Owner.FindComponent(Name+Fields[i].FieldName)) then
              begin
                   Fields[i].Name:=Name+Fields[i].FieldName;
                   RemoveComponent(Fields[i]);
                   Owner.InsertComponent(Fields[i]);
              end;
     end;
end;

procedure TkbmCustomMemTable.SetRecordTag(Value:longint);
var
   p:PkbmRecord;
   r:longint;
begin
     FCommon.Lock;
     try
        p:=GetActiveRecord;
        if p=nil then raise EMemTableError.Create(kbmNoCurrentRecord);
        r:=p^.RecordID;
        if (r<0) or (r>=FCommon.FRecords.Count) then
           raise EMemTableError.Create(kbmNoCurrentRecord);
        PkbmRecord(FCommon.FRecords.Items[r]).Tag:=Value;
        PkbmRecord(p).Tag:=Value;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.GetRecordTag:longint;
var
   p:PkbmRecord;
begin
     Result:=0;
     FCommon.Lock;
     try
        p:=GetActiveRecord;
        if p=nil then raise EMemTableError.Create(kbmNoCurrentRecord);
        Result:=p^.Tag;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.GetIsVersioning:boolean;
begin
     Result:=FCommon.EnableVersioning;
end;

procedure TkbmCustomMemTable.SetStatusFilter(const Value:TUpdateStatusSet);
begin
     CheckBrowseMode;
     UpdateCursorPos;
     if FStatusFilter<>value then
     begin
          FStatusFilter:=Value;
          SetIsFiltered;
          Refresh;
//          Resync([]);
     end;
end;

{$IFNDEF LEVEL3}
function TkbmCustomMemTable.UpdateStatus:TUpdateStatus;
var
   p:PkbmRecord;
begin
     p:=GetActiveRecord;
     if assigned(p) then
        result:=p^.UpdateStatus
     else
         result:=inherited UpdateStatus;
end;
{$ENDIF}

procedure TkbmCustomMemTable.SetAttachedTo(Value:TkbmCustomMemTable);
var
   i:integer;
   fld:TField;
begin
     if Value=FAttachedTo then exit;
     if Value=self then
        raise EMemTableError.Create(kbmCantAttachToSelf);

     Close;

     // Check if attached to something, break the attachment.
     if FAttachedTo<>nil then
     begin
          FCommon.DeAttachTable(self);
          FAttachedTo:=nil;

          // Prepare local memorytable.
          FCommon:=TkbmCommon.Create(self);

          // Add row order index to indexlist.
          with Indexes do
          begin
               FRowOrderIndex:=TkbmIndex.Create(kbmRowOrderIndex,self,'',[],mtitNonSorted,true);
               FRowOrderIndex.FRowOrder:=true;
               AddIndex(FRowOrderIndex);
          end;

          FCommon.Standalone:=false;
     end;

     // Make the new attachment.
     if Value<>nil then
     begin
          // Check if trying to make 3 level attachment. Disallow.
          if Value.FAttachedTo<>nil then
             raise EMemTableError.Create(kbmCantAttachToSelf2);

          // If sort index used before, free it.
          if (FSortIndex<>nil) then
          begin
               Indexes.DeleteIndex(FSortIndex);
               FSortIndex.free;
               FSortIndex:=nil;
          end;

          // Prepare attached to memorytable.
          FCommon.Free;
          FCommon:=Value.FCommon;
          try
             FCommon.AttachTable(self);
          except
             // Prepare local memorytable.
             FCommon:=TkbmCommon.Create(self);
             raise;
          end;
          FAttachedTo:=Value;

          FCurIndex:=Indexes.FRowOrderIndex;

          try
             if (not Value.Active) and (csDesigning in ComponentState) then Value.InternalInitFieldDefs;
          except
          end;

          FieldDefs.Assign(Value.FieldDefs);

          // Make sure fields match attached fields.
          if not (csDesigning in ComponentState) then
          begin
               for i:=0 to FAttachedTo.FieldCount-1 do
               begin
{$IFDEF LEVEL3}
                    fld:=FindField(FAttachedTo.Fields[i].FieldName);
{$ELSE}
                    fld:=FindField(FAttachedTo.Fields[i].FullName);
{$ENDIF}
                    if fld=nil then
                    begin
                         fld:=CreateFieldAs(FAttachedTo.Fields[i]);
                         CopyFieldProperties(FAttachedTo.Fields[i], fld);
//                         fld.visible:=false;
                    end;
               end;
          end;
     end;
end;

// Set filtered property.
procedure TkbmCustomMemTable.SetFiltered(Value:boolean);
begin
     if Value=Filtered then exit;
     inherited;
     if Active then
     begin
{$IFDEF LEVEL5}
          if Value and (FFilterParser=nil) and (Filter<>'') then
          begin
               SetFilterText(Filter);
               SetIsFiltered;
               exit;
          end;
{$ENDIF}
          SetIsFiltered;
          ClearBuffers;
          Refresh;
          First;
     end;
end;

// Parse a filterstring and build filter structure.
procedure TkbmCustomMemTable.SetFilterText(const Value:string);
begin
     inherited;

{$IFDEF LEVEL5}
     // Remove old filter.
     FreeFilter(FFilterParser);
{$ENDIF}

     // If active, build filter.
     if Active then
     begin
{$IFDEF LEVEL5}
          BuildFilter(FFilterParser,Value,FFilterOptions);
{$ENDIF}
          SetIsFiltered;
          if Filtered then
          begin
               ClearBuffers;
               First;
               Refresh;
          end;
     end;
end;

procedure TkbmCustomMemTable.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
     inherited SetOnFilterRecord(Value);
     SetIsFiltered;
end;

// Set delta handler.
procedure TkbmCustomMemTable.SetDeltaHandler(AHandler:TkbmCustomDeltaHandler);
begin
     if FDeltaHandler<>nil then FDeltaHandler.FDataSet:=nil;
     if AHandler<>nil then AHandler.FDataSet:=self;
     FDeltaHandler:=AHandler;
end;

// Set the contents of a memtable from a variant.
procedure TkbmCustomMemTable.SetAllData(AVariant:variant);
var
   ms:TMemoryStream;
begin
     // Check if variant contains data.
     if VarIsEmpty(AVariant) or VarIsNull(AVariant) or (not VarIsArray(AVariant)) then exit;

     ms:=TMemoryStream.Create;
     try
        VariantToStream(AVariant,ms);

        EmptyTable;
        ms.Seek(0,0);
        LoadFromStreamViaFormat(ms,FAllDataFormat);
     finally
        ms.Free;
     end;
end;

function TkbmCustomMemTable.GetAllData:variant;
var
   ms:TMemoryStream;
begin
     Result:=Unassigned;
     if not Active then exit;

     ms:=TMemoryStream.Create;
     try
        SaveToStreamViaFormat(ms,FAllDataFormat);
        Result:=StreamToVariant(ms);
     finally
        ms.Free;
     end;
end;

function TkbmCustomMemTable.GetMasterFields: string;
begin
     Result:=FMasterLink.FieldNames;
end;

procedure TkbmCustomMemTable.SetMasterFields(const Value: string);
begin
     FMasterLink.FieldNames:=Value;

     // Build master field list.
     if Active and (FMasterLink.DataSource<>nil) and (FMasterLink.DataSource.DataSet<>nil) then
        BuildFieldList(FMasterLink.DataSource.DataSet,FMasterIndexList,FMasterLink.FieldNames);
end;

procedure TkbmCustomMemTable.SetDetailFields(const Value: string);
begin
     FDetailFieldNames:=Value;

     // Build detail field list.
     if Active then
        BuildFieldList(self,FDetailIndexList,FDetailFieldNames);
end;

function TkbmCustomMemTable.GetDataSource: TDataSource;
begin
     Result:=FMasterLink.DataSource;
end;

procedure TkbmCustomMemTable.SetDataSource(Value: TDataSource);
begin
     if IsLinkedTo(Value) then DatabaseError(kbmSelfRef{$IFNDEF LEVEL3}, Self{$ENDIF});
     FMasterLink.DataSource:=Value;
end;

procedure TkbmCustomMemTable.MasterChanged(Sender: TObject);
var
   i,n:integer;
   aList:TkbmFieldList;
begin
     SetIsFiltered;

     // Check if no fields defined for master/detail. Do nothing.
     if (FMasterLink.Fields.Count<=0) then exit;

     // check if to use detailfieldlist or indexfieldlist (backwards compability).
     if (FDetailIndexList.Count<=0) then
        aList:=FIndexList
     else
         aList:=FDetailIndexList;
     n:=aList.Count;
     if n<=0 then exit;
     if FMasterLink.Fields.Count<n then n:=FMasterLink.Fields.Count;

     // Check if not allocated master keybuffer.
     if FKeyBuffers[kbmkbMasterDetail]=nil then FKeyBuffers[kbmkbMasterDetail]:=FCommon._InternalAllocRecord;

     // Fill masterrecord with masterfield values.
     for i:=0 to n-1 do
         PopulateField(FKeyBuffers[kbmkbMasterDetail],aList.Fields[i],TField(FMasterLink.Fields.Items[i]).Value);

     // Reposition.
     CheckBrowseMode;
     First;
end;

procedure TkbmCustomMemTable.MasterDisabled(Sender: TObject);
begin
     SetIsFiltered;
     First;
end;

// SetKey, EditKey, FindKey, FindNearest, GotoKey, Ranges.

procedure TkbmCustomMemTable.PrepareKeyRecord(KeyRecordType:integer; Clear:boolean);
begin
     // If keybuffer not assigned, allocate for it.
     if not assigned(FKeyBuffers[KeyRecordType]) then FKeyBuffers[KeyRecordType]:=FCommon._InternalAllocRecord;

     // Switch keybuffer.
     FKeyRecord:=FKeyBuffers[KeyRecordType];
     if Clear then
     begin
          FCommon._InternalFreeRecordVarLengths(FKeyRecord);
          FCommon._InternalClearRecord(FKeyRecord);
     end;
end;

procedure TkbmCustomMemTable.SetKey;
begin
     PrepareKeyRecord(kbmkbKey,true);
     SetState(dsSetKey);
     DataEvent(deDataSetChange, 0);
end;

procedure TkbmCustomMemTable.EditKey;
begin
     PrepareKeyRecord(kbmkbKey,false);
     SetState(dsSetKey);
     DataEvent(deDataSetChange, 0);
end;

function TkbmCustomMemTable.GotoKey:boolean;
var
   Index:integer;
   found:boolean;
begin
     Result:=false;

     CheckBrowseMode;
     
     if not Assigned(FKeyBuffers[kbmkbKey]) then exit;

     SetState(dsBrowse);
     CursorPosChanged;

     // Prepare list of fields representing the keys to search for.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     PrepareKeyRecord(kbmkbKey,false);

     DisableControls;
     try
        // Locate record.
        Index:=-1;
        found:=false;
        FCurIndex.Search(nil,FKeyRecord,false,true,Index,found);
        if found then
        begin
             FRecNo:=Index;
             Result:=true;
             Resync([]);
             DoAfterScroll;
        end;
     finally
        EnableControls;
        SetFound(Result);
     end;
end;

function TkbmCustomMemTable.FindKey(const KeyValues:array of const):boolean;
var
   i,j,k:integer;
   fld:TField;
   SaveState:TDataSetState;
begin
     CheckBrowseMode;

     if FIndexFieldNames='' then raise EMemTableError.Create(kbmVarReason2Err);
     
     PrepareKeyRecord(kbmkbKey,true);

     SaveState:=SetTempState(dsSetKey);
     try
        // Fill values into keyrecord.
        FCurIndex.FIndexFieldList.AssignTo(FIndexList);
        j:=FIndexList.Count-1;
        k:=High(KeyValues);
        if k>=j then k:=j;
        for i:=0 to k do
        begin
             fld:=FIndexList.Fields[i];
             fld.AssignValue(KeyValues[i]);
        end;
     finally
        RestoreState(SaveState);
     end;

     // Goto key.
     Result:=GotoKey;
end;

function TkbmCustomMemTable.FindNearest(const KeyValues:array of const):boolean;
var
   i,j,k:integer;
   fld:TField;
   Index:integer;
   SaveState:TDataSetState;
   Found:boolean;
begin
     CheckBrowseMode;

     // Fill values into keyrecord.
     PrepareKeyRecord(kbmkbKey,true);

     Result:=false;

     SaveState:=SetTempState(dsSetKey);
     try
        FCurIndex.FIndexFieldList.AssignTo(FIndexList);
        j:=FIndexList.Count-1;
        k:=High(KeyValues);
        if k>=j then k:=j;
        for i:=0 to k do
        begin
             fld:=FIndexList.Fields[i];
             fld.AssignValue(KeyValues[i]);
        end;
        SetState(dsBrowse);
        CheckBrowseMode;
        CursorPosChanged;

        DisableControls;
        try
           // Look for record.
           Index:=-1;
//           if (FCurIndex.Search(FIndexList,FKeyRecord,true,true,Index,Found)<=0) and (Index>=0) then
           FCurIndex.Search(FIndexList,FKeyRecord,true,true,Index,Found);
           if (Index>=0) then
           begin
                FRecNo:=Index;
                Result:=true;
           end;

        finally
           EnableControls;
           SetFound(Result);
        end;
     finally
        RestoreState(SaveState);
        if Result then
        begin
             Resync([]);
             DoAfterScroll;
        end;
     end;
end;

procedure TkbmCustomMemTable.SetRangeStart;
begin
     // Prepare setting key values in key records.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     SetState(dsSetKey);
     PrepareKeyRecord(kbmkbRangeStart,true);
     DataEvent(deDataSetChange, 0);
end;

procedure TkbmCustomMemTable.SetRangeEnd;
begin
     // Prepare setting key values in key records.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     SetState(dsSetKey);
     PrepareKeyRecord(kbmkbRangeEnd,true);
     DataEvent(deDataSetChange, 0);
end;

procedure TkbmCustomMemTable.EditRangeStart;
begin
     // Prepare setting key values in key records.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     SetState(dsSetKey);
     PrepareKeyRecord(kbmkbRangeStart,false);
     DataEvent(deDataSetChange, 0);
end;

procedure TkbmCustomMemTable.EditRangeEnd;
begin
     // Prepare setting key values in key records.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);

     SetState(dsSetKey);
     PrepareKeyRecord(kbmkbRangeEnd,false);
     DataEvent(deDataSetChange, 0);
end;

procedure TkbmCustomMemTable.ApplyRange;
begin
     SetState(dsBrowse);
     FRangeActive:=(FKeyBuffers[kbmkbRangeStart]<>nil) and (FKeyBuffers[kbmkbRangeEnd]<>nil);
     SetIsFiltered;
     if not IsEmpty then first;
end;

procedure TkbmCustomMemTable.CancelRange;
var
   n:integer;
begin
     if not FRangeActive then exit;

     if ActiveBuffer<>nil then
        n:=PkbmRecord(ActiveBuffer)^.RecordID
     else
         n:=-1;

     FRangeActive:=false;

     if Active then
     begin
          if n<0 then First
          else FCurIndex.SearchRecordID(n,FRecNo);
          Resync([]);
     end;
end;

procedure TkbmCustomMemTable.SetRange(const StartValues, EndValues:array of const);
var
   i,j,k:integer;
   fld:TField;
begin
     CheckBrowseMode;

     // Prepare setting key values in key records.
     FCurIndex.FIndexFieldList.AssignTo(FIndexList);
     j:=FIndexList.Count-1;

     // Setup start key values.
     SetRangeStart;
     k:=High(StartValues);
     if k>=j then k:=j;
     for i:=0 to k do
     begin
          fld:=FIndexList.Fields[i];
          fld.Clear;
          fld.AssignValue(StartValues[i]);
     end;
     for i:=k+1 to j-1 do
     begin
          fld:=FIndexList.Fields[i];
          fld.Clear;
     end;

     // Setup end key values.
     SetRangeEnd;
     k:=High(EndValues);
     if k>=j then k:=j;
     for i:=0 to k do
     begin
          fld:=FIndexList.Fields[i];
          fld.Clear;
          fld.AssignValue(EndValues[i]);
     end;
     for i:=k+1 to j-1 do
     begin
          fld:=FIndexList.Fields[i];
          fld.Clear;
     end;

     ApplyRange;
end;

procedure TkbmCustomMemTable.DrawAutoInc;
begin
     // Update autoinc if such a field is defined.
     if Assigned(FAutoIncField) and (not FIgnoreAutoIncPopulation) then
        PopulateField(GetActiveRecord,FAutoIncField,FCommon.AutoIncMax+1);
end;

procedure TkbmCustomMemTable.PostAutoInc;
var
   pai:PChar;
   n:integer;
begin
     // If an autoinc field is specified, allways keep track of highest used number.
     if Assigned(FAutoIncField) then
     begin
          pai:=PChar(FCommon.GetFieldPointer(PkbmRecord(ActiveBuffer),FAutoIncField));
          FCommon.Lock;
          try
             n:=PInteger(pai+1)^;
             if (pai[0]<>kbmffNull) and (FCommon.FAutoIncMax<n) then FCommon.FAutoIncMax:=n;
          finally
             FCommon.Unlock;
          end;
     end;
end;

// Copy masterfields to detail table if a master/detail relation.
procedure TkbmCustomMemTable.DoOnNewRecord;
var
   i,n:integer;
   aList:TkbmFieldList;
begin
     // Copy link values from master to detail.
     if FMasterLink.Active and (FMasterLink.Fields.Count > 0) and ((FDetailIndexList.Count>0) or (FIndexList.Count>0)) then
     begin
          // check if to use detailfieldlist or indexfieldlist (backwards compability).
          if (FDetailIndexList.Count<=0) then
             aList:=FIndexList
          else
              aList:=FDetailIndexList;
          n:=FMasterLink.Fields.Count;
          if aList.Count<n then n:=aList.Count;

          for i:=0 to n-1 do
              Alist.Fields[i].Value := TField(FMasterLink.Fields[i]).Value;
     end;

{$IFDEF LEVEL4}
     // If a DefaultExpression exists, fill data with default
     for i:=0 to Fields.Count-1 do
         if (Fields[i].DataType<>ftLargeInt)  // Due to Borland not implementing full largeint support in variants.
            and (Fields[i].DefaultExpression<>'') then
                TField(Fields[i]).Value:=TField(Fields[i]).DefaultExpression;
{$ENDIF}

     inherited DoOnNewRecord;

     DrawAutoInc;
end;

// Update max. autoinc. value.
procedure TkbmCustomMemTable.DoBeforePost;
begin
     inherited;
     PostAutoInc;
end;

procedure TkbmCustomMemTable.DoOnFilterRecord(ADataset:TDataset; var AFiltered:boolean);
begin
     if Assigned(OnFilterRecord) then OnFilterRecord(ADataset,AFiltered);
end;

procedure TkbmCustomMemTable.DestroyIndexes;
begin
     Indexes.Clear;
end;

procedure TkbmCustomMemTable.CreateIndexes;
var
   i:integer;
begin
     Indexes.Clear;

     for i:=0 to FIndexDefs.Count-1 do
         Indexes.Add(FIndexDefs.Items[i]);
end;

function TkbmCustomMemTable.GetIndexByName(IndexName:string):TkbmIndex;
begin
     Result:=Indexes.Get(IndexName);
end;

function TkbmCustomMemTable.IndexFieldCount:Integer;
begin
     Result:=FCurIndex.FIndexFieldList.Count;
end;

function TkbmCustomMemTable.GetIndexField(Index: Integer): TField;
begin
     if (Index<0) or (Index>=IndexFieldCount) then
        Result:=nil
     else
         Result:=FCurIndex.FIndexFieldList.Fields[Index];
end;

procedure TkbmCustomMemTable.SetIndexField(Index:Integer; Value:TField);
var
   s,a:string;
   i:integer;
   lIndex:TkbmIndex;
begin
     // Try to find a predefined index matching this and other specified fields.
     s:='';
     a:='';
     for i:=0 to FCurIndex.FIndexFieldList.count-1 do
         s:=s+a+FCurIndex.FIndexFieldList.Fields[i].FieldName;

     lIndex:=Indexes.GetByFieldNames(s);
     if lIndex<>nil then SwitchToIndex(lIndex);
end;

procedure TkbmCustomMemTable.UpdateIndexes;
var
   i,j:integer;
   lIndex:TkbmIndex;
   DoRefresh:boolean;
begin
     DoRefresh:=false;

     // Check if to delete any indexes.
     for i:=Indexes.Count-1 downto 0 do
     begin
          j:=FIndexDefs.IndexOf(Indexes.FIndexes.Strings[i]);
          if j<0 then
          begin
               lIndex:=TkbmIndex(Indexes.FIndexes.Objects[i]);
               if (lIndex = Indexes.FRowOrderIndex) or (lIndex = FSortIndex) then continue;
               Indexes.FIndexes.Delete(i);
               if lIndex = FCurIndex then
               begin
                    FCurIndex:=Indexes.FRowOrderIndex;
                    DoRefresh:=true;
//                    Resync([]);
                    FIndexFieldNames:='';
               end;
               lIndex.free;
          end;
     end;

     // Check if to add any indexes.
     for i:=0 to FIndexDefs.Count-1 do
     begin
          with FIndexDefs.Items[i] do
          begin
               j:=Indexes.FIndexes.IndexOf(FIndexDefs.Items[i].Name);
               if j<0 then
               begin
                    lIndex:=TkbmIndex.Create(Name,self,Fields,IndexOptions2CompareOptions(Options),mtitSorted,false);
                    Indexes.AddIndex(lIndex);
               end;
          end;
     end;

     // Check if to rebuild any indexes.
     for i:=0 to Indexes.Count-1 do
     begin
          lIndex:=TkbmIndex(Indexes.FIndexes.Objects[i]);
          if not lIndex.FOrdered then
          begin
               lIndex.Rebuild;
               if (lIndex = FCurIndex) and (Active) then DoRefresh:=true; // Resync([]);
          end;
     end;

     if DoRefresh then Refresh;
end;

function TkbmCustomMemTable.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
     Result:=TkbmBlobStream.Create(Field as TBlobField, Mode);
end;

procedure TkbmCustomMemTable.CreateTable;
var
   i:Integer;
begin
     DoCheckInactive;

     // If no fielddefs existing, use the previously defined fields.
     if FieldDefs.Count = 0 then
        for i:=0 to FieldCount-1 do
            with Fields[i] do
                 if FieldKind = fkData then
                    FieldDefs.Add(FieldName, DataType, Size, Required);

     // Check if to many fielddefs in source.
     if FieldDefs.Count>KBM_MAX_FIELDS then
        raise EMemTableError.Create(kbmTooManyFieldDefs);

     // Remove previously defined fields and indexes.
     DestroyIndexes;
     DestroyFields;

     // Create fields and indexes.
     CreateFields;
     CreateIndexes;

     ResetAutoInc;
end;

// Create field as another field.
function TkbmCustomMemTable.CreateFieldAs(Field:TField):TField;
var
   cl:TFieldClass;
begin
     Result:=nil;

{$IFDEF KBM} // FOR DELETION
//{$IFDEF LEVEL3}
     if Field.DataType in [{$IFDEF LEVEL5},ftGUID{$ENDIF}] then
        cl:=TStringField
     else
     begin
          if not (Field.DataType in kbmSupportedFieldTypes) then exit;
          cl:=TFieldClass(Field.ClassType);
     end;
//{$ELSE}
{$ENDIF} // FOR DELETION
     if not (Field.DataType in kbmSupportedFieldTypes) then exit;
     cl:=TFieldClass(Field.ClassType);
//{$ENDIF}
     Result:=cl.Create(owner);
     Result.Size:=Field.Size;
     Result.FieldKind:=Field.FieldKind;
     Result.FieldName:=Field.FieldName;
     Result.Lookup:=Field.Lookup;
     Result.KeyFields:=Field.KeyFields;
     Result.LookupDataSet:=Field.LookupDataSet;
     Result.LookupResultField:=Field.LookupResultField;
     Result.LookupKeyFields:=Field.LookupKeyFields;
{$IFDEF LEVEL4}
     if Field is TBCDField then
        TBCDField(Result).Precision:=TBCDField(Field).Precision;
{$ENDIF}
     Result.DataSet:=self;
end;

// Create memory table as another dataset.
procedure TkbmCustomMemTable.CreateTableAs(Source:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions);
{$IFNDEF LEVEL3}
  procedure AssignFieldDef(Src,Dest:TFieldDef);
  var
     i:integer;
  begin
       with Dest do
       begin
            if Collection <> nil then Collection.BeginUpdate;
            try
               // FieldNo is defaulted.
               Name := Src.Name;
               DataType := Src.DataType;
               Size := Src.Size;
               Precision := Src.Precision;
               Attributes := Src.Attributes;
               InternalCalcField := Src.InternalCalcField;
               if HasChildDefs then ChildDefs.Clear;
               if Src.HasChildDefs then
                 for i := 0 to Src.ChildDefs.Count - 1 do
                   AssignFieldDef(Src.ChildDefs[i],AddChild);
            finally
               if Collection <> nil then Collection.EndUpdate;
            end;
       end;
  end;
{$ENDIF}
var
   i:integer;
   fld:TField;
begin
     DoCheckInactive;

     if Source=nil then exit;

     // Add fields as they are defined in the other dataset.
     if not Source.Active then Source.FieldDefs.Update;

     // Check if to many fielddefs in source.
     if Source.FieldDefs.Count>KBM_MAX_FIELDS then
        raise EMemTableError.Create(kbmTooManyFieldDefs);

     FieldDefs.Clear;
{$IFNDEF LEVEL3}
     for i:=0 to Source.FieldDefs.Count-1 do
         AssignFieldDef(Source.FieldDefs.Items[i],FieldDefs.AddFieldDef);
{$ELSE}
     FieldDefs.Assign(Source.FieldDefs);
{$ENDIF}

     // Check which fielddefs we wont keep and potentially convert datatypes.
     for i:=FieldDefs.Count-1 downto 0 do
     begin
          // Remove non supported fieldsdefs.
          if not (FieldDefs.Items[i].DataType in kbmSupportedFieldTypes) then
             FieldDefs.Items[i].free

          // Remove nonactive fields.
          else if (mtcpoOnlyActiveFields in CopyOptions) and
                  (Source.FindField(FieldDefs.Items[i].Name)=nil) then
                      FieldDefs.Items[i].free

{$IFDEF LEVEL6}
          // Check if to convert string fields to widestring fields.
          else if (mtcpoStringAsWideString in CopyOptions) and
               (FieldDefs.Items[i].DataType in [ftString,ftFixedChar]) then
               FieldDefs.Items[i].DataType:=ftWideString

{$ENDIF}
          ;
     end;

     // Destroy existing fields.
     DestroyFields;
     if not Source.DefaultFields then CreateFields;

     // Copy lookup and calculated fields if specified.
     for i:=0 to Source.FieldCount-1 do
         if ((Source.Fields[i].FieldKind=fkLookup) and (mtcpoLookup in CopyOptions))
            or ((Source.Fields[i].FieldKind=fkCalculated) and (mtcpoCalculated in CopyOptions)) then
         begin
              fld:=CreateFieldAs(Source.Fields[i]);
              if mtcpoFieldIndex in CopyOptions then fld.Index:=Source.Fields[i].Index;
         end;

     // Copy fieldproperties from source.
     if mtcpoProperties in CopyOptions then CopyFieldsProperties(Source,self);

     ResetAutoInc;
end;

// Delete table.
procedure TkbmCustomMemTable.DeleteTable;
begin
     DoCheckInactive;
     DestroyFields;
end;

procedure TkbmCustomMemTable.CheckActive;
begin
     inherited;
//     if not FCommon.IsAnyTableActive then
//        DatabaseError(SDataSetClosed{$IFNDEF LEVEL3},Self{$ENDIF});
end;

procedure TkbmCustomMemTable.CheckInActive;
begin
     inherited;
end;

procedure TkbmCustomMemTable.DoCheckInActive;
begin
     inherited;
     if FCommon.IsAnyTableActive then
        FCommon.CloseTables(nil)
end;

function TkbmCustomMemTable.GetModifiedFlags(i:integer):boolean;
begin
     Result:=false;
     FCommon.Lock;
     try
        if (i<0) or (i>=FieldCount) then raise ERangeError.CreateFmt(kbmOutOfRange,[i]);
        Result:=(FCommon.FFieldFlags[i] and kbmffModified)<>0;
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.GetLocaleID:integer;
begin
     Result:=FCommon.LocaleID;
end;

procedure TkbmCustomMemTable.SetLocaleID(Value:integer);
begin
     FCommon.LocaleID:=Value;
end;

function TkbmCustomMemTable.GetLanguageID:integer;
begin
     Result:=FCommon.LanguageID;
end;

procedure TkbmCustomMemTable.SetLanguageID(Value:integer);
begin
     FCommon.LanguageID:=Value;
end;

function TkbmCustomMemTable.GetSortID:integer;
begin
     Result:=FCommon.SortID;
end;

procedure TkbmCustomMemTable.SetSortID(Value:integer);
begin
     FCommon.SortID:=Value;
end;

function TkbmCustomMemTable.GetSubLanguageID:integer;
begin
     Result:=FCommon.SubLanguageID;
end;

procedure TkbmCustomMemTable.SetSubLanguageID(Value:integer);
begin
     FCommon.SubLanguageID:=Value;
end;

procedure TkbmCustomMemTable.CreateFieldDefs;
var
   i:integer;
begin
     FieldDefs.clear;
     for i:=0 to Fieldcount-1 do
     begin
          // Add fielddef.
          if Fields[i].FieldKind in [fkData,fkInternalCalc] then
             FieldDefs.Add(Fields[i].FieldName,Fields[i].DataType,Fields[i].Size,Fields[i].Required);
     end;
end;

procedure TkbmCustomMemTable.InternalOpen;
begin
     // Check if owner table is open.
     if (Self<>FCommon.FOwner) and (not FCommon.FOwner.Active) then FCommon.FOwner.Open;

     // Attach to common.
     FCommon.Lock;
     try
        InternalInitFieldDefs;
        if Self=FCommon.FOwner then
        begin
             if DefaultFields then
             begin
                  if (Self=FCommon.FOwner) and (FieldDefs.Count<=0) then
                     raise EMemTableError.Create(kbmVarReason2Err);
                  CreateFields;
             end
             else
                 CreateFieldDefs;
             ResetAutoInc;
        end
        else
            if DefaultFields then CreateFields;

        // Setup size of bookmark as exposed to applications.
        // Bookmark contains record pointer + a 2 byte table identifier.
        BookmarkSize := sizeof(TkbmUserBookmark);

        BindFields(True);

        // If Im the owner then layout the records.
        if FCommon.FOwner=self then FCommon.LayoutRecord(FieldCount);

        FIsOpen:=True;
        FRecNo:=-1;
        FReposRecNo:=-1;

        // Prepare index.
        CreateIndexes;

        // Select roworder index. Designtime selected alternative index will be selected in AfterOpen.
        FCurIndex:=Indexes.FRowOrderIndex;

        // Build master field list.
        if (FMasterLink.FieldNames<>'') and (FMasterLink.DataSource<>nil) and (FMasterLink.DataSource.DataSet<>nil) then
           BuildFieldList(FMasterLink.DataSource.DataSet,FMasterIndexList,FMasterLink.FieldNames)
        else
            FMasterIndexList.Clear;

        // Build detail field list.
        if (FDetailFieldNames<>'') then
           BuildFieldList(Self,FDetailIndexList,FDetailFieldNames)
        else
            FDetailIndexList.Clear;

        ClearBuffers;

        // Set flag that before close has not yet been called (used by destructor).
        FBeforeCloseCalled:=false;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.InternalClose;
var
   i:integer;
begin
     // Check if to call before close.
     if not FBeforeCloseCalled then DoBeforeClose;

     FCommon.Lock;
     try
        // Check if owner, close others and empty table.
        if FCommon.FOwner=self then
        begin
             EmptyTable;
             FCommon.CloseTables(self);
        end;
     finally
        FCommon.Unlock;
     end;

     FRecNo:=-1;

     // Remove all indexes (except roworderindex).
     DestroyIndexes;
     FCurIndex:=Indexes.FRowOrderIndex;

     FIsOpen:=False;
     BindFields(False);

     // Delete keybuffers if assigned.
     FKeyRecord:=nil;
     for i:=kbmkbMin to kbmkbMax do
         if Assigned(FKeyBuffers[i]) then
         begin
              FCommon._InternalFreeRecord(FKeyBuffers[i],true,false);
              FKeyBuffers[i]:=nil;
         end;

     if DefaultFields then DestroyFields;
end;

procedure TkbmCustomMemTable.ResetAutoInc;
begin
     FAutoIncField:=nil;
     FCommon.AutoIncMax:=FCommon.AutoIncMin-1;
     CheckAutoInc;
end;

function TkbmCustomMemTable.CheckAutoInc:boolean;
var
   i:integer;
begin
     Result:=False;
     for i:=0 to FieldCount-1 do
         if Fields[i].DataType=ftAutoInc then
         begin
              FAutoIncField:=Fields[i];
              Result:=True;
              break;
         end;
end;

procedure TkbmCustomMemTable.InternalInitFieldDefs;
begin
     // Check if attached to another table, use that tables definitions.
     if FAttachedTo<>nil then
     begin
          FAutoIncField:=FAttachedTo.FAutoIncField;
          FieldDefs.Assign(FAttachedTo.FieldDefs);
          exit;
     end;

     // If using predefined fields, generate fielddefs according to fields.
     if not DefaultFields then
        CreateFieldDefs;

     // Look for autoinc field if any.
     ResetAutoInc;
end;

function TkbmCustomMemTable.GetActiveRecord:PkbmRecord;
var
   RecID:integer;
begin
     FCommon.Lock;
     try
        // Check if to return a pointer to a specific buffer.
        if FOverrideActiveRecordBuffer<>nil then
        begin
             Result:=FOverrideActiveRecordBuffer;
             exit;
        end;

        // Else return depending on dataset state.
        case State of
             dsBrowse:              if IsEmpty then
                                       Result := nil
                                    else
                                       Result := PkbmRecord(ActiveBuffer);

             dsCalcFields:          Result := PkbmRecord(CalcBuffer);

             dsFilter:              Result:=FFilterRecord;

             dsEdit:                Result:=PkbmRecord(ActiveBuffer);

             dsInsert:              Result:=PkbmRecord(ActiveBuffer);

             dsNewValue,dsCurValue: Result:=PkbmRecord(ActiveBuffer);

             dsOldValue:            begin
                                         // Return database record as result.
                                         // According to the description of TField.OldValue in the help files,
                                         // OldValue should return the original value of the field before the
                                         // field is posted to. After the post, the oldvalue=curvalue.
                                         // Since the data in the table has not been updated before the post,
                                         // and currently edited data is in the active workrecord only, accessing
                                         // the tahle record will return the original record.
                                         // CHANGED 25. FEB. 2002 KBM
                                         // To make it more compatible with the workings of TClientDataset,
                                         // it will instead return the original unchanged version of the record
                                         // if one exists.
                                         RecID:=PkbmRecord(ActiveBuffer)^.RecordID;
                                         if (RecID>=0) then
                                         begin
                                              Result:=PkbmRecord(FCommon.FRecords.Items[RecID]);
                                              while Result^.PrevRecordVersion<>nil do
                                                    Result:=Result^.PrevRecordVersion;
                                         end
                                         else
                                             Result:=PkbmRecord(ActiveBuffer);
                                    end;

             dsSetKey:              Result:=FKeyRecord;
{$IFDEF LEVEL4}
             dsBlockRead:           Result:=PkbmRecord(ActiveBuffer);
{$ENDIF}
        else
             Result:=nil;
        end;
     finally
        FCommon.Unlock;
     end;
end;

{$IFDEF LEVEL5}
{$IFNDEF DOTNET}
procedure TkbmCustomMemTable.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);
{$ELSE}
procedure TkbmCustomMemTable.DataConvert(Field: TField; Source, Dest: TValueBuffer; ToNative: Boolean);
{$ENDIF}
begin
     case Field.DataType of
          ftWideString:
            // If to convert to native internal storage.
            if ToNative then
            begin
                 WideStringToBuffer(PWideString(Source)^,Dest);
            end
            else
            // convert from internal native storage to api value.
            begin
                 // Must size the receiving widestring.
                 PWideString(Dest)^:=WideStringFromBuffer(Source);
            end;

          else
            inherited DataConvert(Field,Source,Dest,ToNative);
     end;
end;
{$ENDIF}

// Result is data in the buffer and a boolean return (true=not null, false=is null).
function TkbmCustomMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
   SourceBuffer:PChar;
   ActRec,CurRec:PkbmRecord;
   IsVarLength,IsCompressed:boolean;
   pVarLength:PkbmVarLength;
   RecID:longint;
   cBuffer:PChar;
   cSz:longint;
begin
     FCommon.Lock;
     try
        Result:=False;
        if not FIsOpen then exit;
        ActRec:=GetActiveRecord;
        if ActRec=nil then exit;
        SourceBuffer:=FCommon.GetFieldPointer(ActRec,Field);
        if SourceBuffer=nil then Exit;

        // Check if calculated field. At the same time check for if varlength field.
        if Field.FieldKind<>fkData then
        begin
             IsVarLength:=false;
             IsCompressed:=false;
        end
        else
        begin
             IsVarLength:=(FCommon.FFieldFlags[Field.FieldNo-1] and kbmffIndirect)<>0;
             IsCompressed:=(FCommon.FFieldFlags[Field.FieldNo-1] and kbmffCompress)<>0;
        end;

        // Return null status.
        Result:=SourceBuffer[0]<>kbmffNull;
        if not Result then exit;

        // Check if varlength field, get the data indirectly. If no data avail. get the data from the db.
        if IsVarLength then
        begin
             pVarLength:=PPkbmVarLength(SourceBuffer+1)^;

             // If varlength field not populated, check if database original populated.
             if (pVarLength = nil) then
             begin
                  // Find the record in the recordlist using the unique record id.
                  RecID:=ActRec^.RecordID;
                  if (RecID>=0) then
                  begin
                       CurRec:=PkbmRecord(FCommon.FRecords.Items[RecID]);
                       cBuffer:=FCommon.GetFieldPointer(CurRec,Field);
                       pVarLength:=PPkbmVarLength(cBuffer+1)^;
                  end

                  // If by any chance no valid recordis is found, something is really rotten.
                  else if Assigned(Buffer) then
                      raise EMemTableInvalidRecord.Create(kbmInvalidRecord);
             end;

             // Check if to get data or not. Blobfields dont return data.
             if (not (Field.DataType in kbmBlobTypes))
                and Assigned(Buffer) and (pVarLength<>nil) then
             begin
                  cBuffer:=GetVarLengthData(pVarLength);
                  cSz:=GetVarLengthSize(pVarLength);

                  // Check if compressed field, decompress buffer.
                  if IsCompressed then
                  begin
                       if Assigned(FCommon.FOwner.FOnDeCompressField) then
                          FCommon.FOwner.FOnDecompressField(self,Field,CBuffer,cSz,CBuffer)
                       else
                           CBuffer:=FCommon.DecompressFieldBuffer(Field,CBuffer,CSz);
                  end;

{$IFNDEF USE_FAST_MOVE}
                      Move(cBuffer^,Buffer^,cSz);
{$ELSE}
                      FastMove(cBuffer^,Buffer^,cSz);
{$ENDIF}
             end;
        end
        else
        begin
             if Assigned(Buffer) then
             begin
{$IFNDEF USE_FAST_MOVE}
                  Move(SourceBuffer[1], Buffer^, FCommon.GetFieldSize(Field.DataType,Field.Size));
{$ELSE}
                  FastMove(SourceBuffer[1], Buffer^, FCommon.GetFieldSize(Field.DataType,Field.Size));
{$ENDIF}
             end;
        end;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.SetFieldData(Field: TField; Buffer: Pointer);
var
   DestinationBuffer: PChar;
   ppVarLength:PPkbmVarLength;
   IsVarLength,IsCompressed:boolean;
   sz:longint;
   n:integer;
   cBuffer:PChar;
   cSz:longint;
begin
     if not FIsOpen then exit;

     FCommon.Lock;
     try
        if not (State in (dsWriteModes+[dsCalcFields])) then DatabaseError(kbmEditModeErr{$IFNDEF LEVEL3}, Self{$ENDIF});
        DestinationBuffer:=FCommon.GetFieldPointer(GetActiveRecord,Field);
        if DestinationBuffer=nil then Exit;

        if (not FIgnoreReadOnly) and ((FReadOnly or Field.ReadOnly) and (State<>dsSetKey)) then
           DatabaseErrorFmt(kbmReadOnlyErr,[Field.DisplayName]);

        sz:=FCommon.GetFieldSize(Field.DataType,Field.Size);

        // Set the null value from the buffer.
        if LongBool(Buffer) then DestinationBuffer^:=kbmffData
        else DestinationBuffer^:=kbmffNull;
        inc(DestinationBuffer);

        // Check if calculated field. At the same time check for if varlength field.
        if Field.FieldKind in [fkData,fkInternalCalc,fkCalculated] then Field.Validate(Buffer);
        if Field.FieldKind<>fkData then
        begin
             IsVarLength:=false;
             IsCompressed:=false;
        end
        else
        begin
             IsVarLength:=(FCommon.FFieldFlags[Field.FieldNo-1] and kbmffIndirect)<>0;
             IsCompressed:=(FCommon.FFieldFlags[Field.FieldNo-1] and kbmffCompress)<>0;
        end;

        // Check if varlength field, set the data indirectly.
        if IsVarLength then
        begin
             ppVarLength:=PPkbmVarLength(DestinationBuffer);

             // If varlength field populated, clear it out.
             if (ppVarLength^ <> nil) then
             begin
                  FreeVarLength(ppVarLength^);
                  ppVarLength^:=nil;
             end;

             // Check if to populate the varlength field.
             if Assigned(Buffer) then
             begin
                  cBuffer:=Buffer;
                  cSz:=sz;

                  // Check if to compress the data.
                  if IsCompressed then
                  begin
                       if Assigned(FCommon.FOwner.FOnCompressField) then
                          FCommon.FOwner.FOnCompressField(self,Field,Buffer,cSz,CBuffer)
                       else
                           CBuffer:=FCommon.CompressFieldBuffer(Field,Buffer,CSz);
                  end;

                  ppVarLength^:=AllocVarLengthAs(CBuffer,CSz);
             end;
        end
        else
        begin
             if Assigned(Buffer) then
             begin
{$IFNDEF USE_FAST_MOVE}
                  Move(Buffer^,DestinationBuffer^,sz);
{$ELSE}
                  FastMove(Buffer^,DestinationBuffer^,sz);
{$ENDIF}
             end;
        end;

        // Set modified flag.
        n:=Field.FieldNo-1;
        if (n>=0) then FCommon.FFieldFlags[n]:=FCommon.FFieldFlags[n] or kbmffModified;

        if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
           DataEvent(deFieldChange, Longint(Field));
     finally
        FCommon.Unlock;
     end;
end;

function TkbmCustomMemTable.IsCursorOpen: Boolean;
begin
     Result:=FIsOpen;
end;

function TkbmCustomMemTable.GetCanModify: Boolean;
begin
     Result:=not FReadOnly;
end;

function TkbmCustomMemTable.GetRecordSize: Word;
begin
     Result:=FCommon.FTotalRecordSize;
end;

function TkbmCustomMemTable.AllocRecordBuffer: PChar;
begin
     Result:=PChar(FCommon._InternalAllocRecord);
end;

procedure TkbmCustomMemTable.FreeRecordBuffer(var Buffer: PChar);
begin
     FCommon._InternalFreeRecord(PkbmRecord(Buffer),false,false);
     Buffer:=nil;
end;

{$IFDEF LEVEL4}
procedure TkbmCustomMemTable.SetBlockReadSize(Value: Integer);
{$IFNDEF LEVEL5}
var
   DoNext: Boolean;
{$ENDIF}
begin
     if Value <> BlockReadSize then
     begin
          if (Value > 0) or (Value < -1) then
          begin
               inherited;
               BlockReadNext;
          end
          else
          begin
{$IFNDEF LEVEL5}
               DoNext:=Value=-1;
{$ENDIF}
               Value:=0;
               inherited;

{$IFNDEF LEVEL5}
               if DoNext then
                  Next
               else
               begin
{$ENDIF}
                    CursorPosChanged;
                    Resync([]);
{$IFNDEF LEVEL5}
               end;
{$ENDIF}
          end;
     end;
end;
{$ENDIF}

// Fill one field with contents of a variant.
procedure TkbmCustomMemTable.PopulateField(ARecord:PkbmRecord; Field:TField; AValue:Variant);
var
   p:PChar;
   pValue:PChar;

   s:array[0..dsMaxStringSize] of Char;
   fn:integer;
   si:smallint;
{$IFDEF LEVEL5}
   bcd:TBcd;
   c:Currency;
{$ENDIF}
{$IFNDEF LEVEL3}
   li:Int64;
   ws:WideString;
{$ENDIF}
   i:integer;
   w:word;
   d:double;
   wb:WordBool;
   dt:TDateTime;
   ts:TTimeStamp;
   dtr:TDateTimeRec;
   flags:byte;
   sz:longint;
   CSz:longint;
   CBuffer:PChar;
   ppVarLength:PPkbmVarLength;
{$IFDEF LEVEL6}
   tssql:TSQLTimeStamp;
{$ENDIF}
begin
     p:=FCommon.GetFieldPointer(ARecord,Field);
     sz:=FCommon.GetFieldSize(Field.DataType, Field.Size);

     FCommon.Lock;
     try
        // Populate with null?
        if VarIsNull(AValue) or VarIsEmpty(AValue) then
        begin
             p[0]:=kbmffNull;
             FillChar(p[1],sz, 0);
             exit;
        end;

        // Populate with value.
        p[0]:=kbmffData;
        with Field do
        begin
             pValue:=nil;
             case DataType of
{$IFNDEF LEVEL3}
                  ftWideString:
                      begin
                           ws:=AValue;
                           pValue:=PChar(@ws);
                      end;

                  ftFixedChar,
{$ENDIF}
{$IFDEF LEVEL5}
                  ftGUID,
{$ENDIF}
                  ftString:
                      begin
                           StrLCopy(s,PChar(VarToStr(AValue)),DataSize);
                           if TStringField(Field).Transliterate then
                              DataSet.Translate(s,s,True);
                           pValue:=s;
                      end;

                  ftSmallint:
                      begin
                           si:=AValue;
                           pValue:=PChar(@si);
                      end;
{$IFNDEF LEVEL3}
                  ftLargeInt:
                      begin
                           li:=trunc(double(AValue));
                           pValue:=PChar(@li);
                      end;
{$ENDIF}
                  ftInteger,
                  ftAutoInc:
                      begin
                           i:=AValue;
                           pValue:=PChar(@i);
                      end;

{$IFDEF LEVEL5}
                  ftBCD:
                      begin
                           c:=AValue;
                           CurrToBCD(c,bcd,TBCDField(Field).Precision,TBCDField(Field).Size);
                           pValue:=PChar(@bcd);
                      end;
{$ENDIF}

                  ftDate:
                      begin
                           if VarType(AValue) in [varDate,varDouble,varSingle,varInteger] then
                              dt:=AValue
                           else
                              dt:=StrToDateTime(VarToStr(AValue));
                           ts:=DateTimeToTimeStamp(dt);
                           dtr.Date:=ts.Date;
                           pValue:=PChar(@dtr);
                      end;

                  ftTime:
                      begin
                           if VarType(AValue) in [varDate,varDouble,varSingle,varInteger] then
                              dt:=AValue
                           else
                              dt:=StrToDateTime(VarToStr(AValue));
                           ts:=DateTimeToTimeStamp(dt);
                           dtr.Time:=ts.Time;
                           pValue:=PChar(@dtr);
                      end;

                  ftDateTime:
                      begin
                           if VarType(AValue) in [varDate,varDouble,varSingle,varInteger] then
                              dt:=AValue
                           else
                              dt:=StrToDateTime(VarToStr(AValue));
                           ts:=DateTimeToTimeStamp(dt);
                           dtr.DateTime:=TimeStampToMSecs(ts);
                           pValue:=PChar(@dtr);
                      end;
{$IFDEF LEVEL6}
                  ftTimeStamp:
                      begin
                           tssql:=VarToSQLTimeStamp(AValue);
                           pValue:=PChar(@tssql);
                      end;
{$ENDIF}

                  ftWord:
                      begin
                           w:=AValue;
                           pValue:=PChar(@w);
                      end;

                  ftBoolean:
                      begin
                           wb:=AValue;
                           pValue:=PChar(@wb);
                      end;

                  ftFloat,
                  ftCurrency:
                      begin
                           d:=AValue;
                           pValue:=PChar(@d);
                      end;
             end;

             // If anything to store.
             if (pValue<>nil) then
             begin
                  // Check if varlength field, set the data indirectly.
                  inc(p);
                  fn:=Field.FieldNo-1;
                  if fn>=0 then      // Calculated fields are never varlengths.
                  begin
                       flags:=FCommon.FFieldFlags[fn];
                       if (flags and kbmffIndirect)<>0 then
                       begin
                            ppVarLength:=PPkbmVarLength(p);

                            // If varlength field populated, clear it out.
                            if (ppVarLength^ <> nil) then
                            begin
                                 FreeVarLength(ppVarLength^);
                                 ppVarLength^:=nil;
                            end;

                            // Check if to populate the varlength field.
                            cBuffer:=pValue;
                            cSz:=sz;

                            // Check if to compress the data.
                            if (flags and kbmffCompress)<>0 then
                            begin
                                 if Assigned(FOnCompressField) then
                                    FCommon.FOwner.FOnCompressField(self,Field,pValue,cSz,CBuffer)
                                 else
                                     CBuffer:=FCommon.CompressFieldBuffer(Field,pValue,CSz);
                            end;

                            ppVarLength^:=AllocVarLengthAs(CBuffer,CSz);
                       end
                       else
{$IFNDEF USE_FAST_MOVE}
                           Move(pValue^,p^,sz);
{$ELSE}
                           FastMove(pValue^,p^,sz);
{$ENDIF}

                       FCommon.FFieldFlags[fn]:=FCommon.FFieldFlags[fn] or kbmffModified;
                  end
                  else
{$IFNDEF USE_FAST_MOVE}
                      Move(pValue^,p^,sz);
{$ELSE}
                      FastMove(pValue^,p^,sz);
{$ENDIF}
             end;
        end;
     finally
        FCommon.Unlock;
     end;
end;

// Populate a varlength field with a value.
procedure TkbmCustomMemTable.PopulateVarLength(ARecord:PkbmRecord;Field:TField;const Buffer;Size:integer);
var
   pField:PChar;
   pVarLength:PPkbmVarLength;
begin
     pField:=FCommon.GetFieldPointer(ARecord,Field);
     if pField=nil then exit;

     pVarLength:=PPKbmVarLength(pField+1);
     if pVarLength^<>nil then
     begin
          FreeVarLength(pVarLength^);
          pVarLength^:=nil;
     end;

     pVarLength^:=AllocVarLength(Size);

     if Size<>0 then
     begin
          pField[0]:=kbmffData;
{$IFNDEF USE_FAST_MOVE}
          Move(Buffer, GetVarLengthData(pVarLength^)^,Size);
{$ELSE}
          FastMove(Buffer, GetVarLengthData(pVarLength^)^,Size);
{$ENDIF}
     end
     else
         pField[0]:=kbmffNull;
end;

// Fill record with values for specified fields.
procedure TkbmCustomMemTable.PopulateRecord(ARecord:PkbmRecord; Fields:string; Values:variant);
var
   FieldList:TkbmFieldList;
   i:integer;
   n:integer;
begin
     FieldList := TkbmFieldList.Create;
     try
        BuildFieldList(self,FieldList,Fields);

        n:=VarArrayDimCount(Values);
        if n>1 then raise EMemTableError.Create(kbmVarArrayErr);
        if (n=0) and (FieldList.count>1) then raise EMemTableError.Create(kbmVarReason1Err);
        if FieldList.Count<1 then raise EMemTableError.Create(kbmVarReason2Err);

        // Single value.
        if n=0 then
        begin
             PopulateField(ARecord,FieldList.Fields[0],Values);
             exit;
        end;

        // Several values.
        for i:=0 to FieldList.Count-1 do
        begin
             PopulateField(ARecord,FieldList.Fields[i],Values[i]);
        end;
     finally
        FieldList.free;
     end;
end;

procedure TkbmCustomMemTable.InternalFirst;
begin
     _InternalFirst;
end;

procedure TkbmCustomMemTable.InternalLast;
begin
     _InternalLast;
end;

procedure TkbmCustomMemTable._InternalFirst;
begin
     FRecNo:=-1;
end;

procedure TkbmCustomMemTable._InternalLast;
begin
     FRecNo:=FCurIndex.FReferences.Count;
end;

function TkbmCustomMemTable._InternalNext(ForceUseFilter:boolean):boolean;
var
   pRec:PkbmRecord;
begin
     // If not filtered.
     if not (ForceUseFilter or IsFiltered) then
     begin
          Result:=(FRecNo<FCurIndex.FReferences.Count-1);
          if Result then Inc(FRecNo);
          exit;
     end;

     // Handle filtering.
     Result:=false;
     while FRecNo<FCurIndex.FReferences.Count-1 do
     begin
          Inc(FRecNo);
          pRec:=PkbmRecord(FCurIndex.FReferences.Items[FRecNo]);
          if FilterRecord(pRec,ForceUseFilter) then
          begin
               Result:=true;
               break;
          end;
     end;
end;

function TkbmCustomMemTable._InternalPrior(ForceUseFilter:boolean):boolean;
var
   pRec:PkbmRecord;
begin
     // If not filtered.
     if not (ForceUseFilter or IsFiltered) then
     begin
          Result:=(FRecNo>0);
          if Result then Dec(FRecNo);
          exit;
     end;

     // Handle filtering.
     Result:=false;
     while FRecNo>0 do
     begin
          Dec(FRecNo);
          pRec:=PkbmRecord(FCurIndex.FReferences.Items[FRecNo]);
          if FilterRecord(pRec,ForceUseFilter) then
          begin
               Result:=true;
               break;
          end;
     end;
end;

// Getrecord fetches valid nonfiltered record.
// Only fixed record contents are copied to the buffer.
// All varchars are only referenced to record in recordlist.
// All versions are only referenced to recordversions in recordlist.
function TkbmCustomMemTable.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
   pRec:PkbmRecord;
   pbmData:PkbmBookmark;
begin
     case GetMode of
          gmCurrent: begin
                          if FRecNo>=FCurIndex.FReferences.Count then Result:=grEOF
                          else if FRecNo<0 then Result:=grBOF
                          else
                          begin
                               Result:=grOK;
                               if IsFiltered then
                               begin
                                    pRec:=PkbmRecord(FCurIndex.FReferences.Items[FRecNo]);
                                    if not FilterRecord(pRec,false) then Result:=grEOF;
                               end;
                          end;
                     end;
          gmNext:    begin
                          if _InternalNext(false) then Result:=grOK
                          else Result:=grEOF;
                     end;
          gmPrior:   begin
                          if _InternalPrior(false) then Result:=grOK
                          else Result:=grBOF;
                     end;
          else
              Result:=grOK;
     end;
     if Result=grOk then
     begin
          pRec:=PkbmRecord(FCurIndex.FReferences.Items[FRecNo]);

          // Fill record part of buffer
          FCommon._InternalFreeRecordVarLengths(PkbmRecord(Buffer));
          FCommon._InternalClearRecord(PkbmRecord(Buffer));

          // Move record contents to avoid copying all versions and varlengths just for scrolling through records.
          FCommon._InternalMoveRecord(pRec,PkbmRecord(Buffer));

          //fill information part of buffer
          with PkbmRecord(Buffer)^ do
          begin
               RecordNo:=FRecNo;
               RecordID:=pRec^.RecordID;
               UniqueRecordID:=pRec^.UniqueRecordID;

               // Setup bookmark data.
               pbmData:=PkbmBookmark(Data+FCommon.FStartBookmarks);
               inc(pbmData,FTableID);
               pbmData^.Bookmark:=pRec;
               pbmData^.Flag:=bfCurrent;

               Flag:=Flag and (not (kbmrfIntable));
          end;
          if FRecalcOnFetch then
             GetCalcFields(Buffer);
     end
     else
         if (GetMode=gmCurrent) then Result:=grError;
end;

function TkbmCustomMemTable.FindRecord(Restart, GoForward: Boolean): Boolean;
var
   Status:boolean;
begin
     CheckBrowseMode;
     DoBeforeScroll;
     SetFound(False);
     UpdateCursorPos;
     CursorPosChanged;

     if GoForward then
     begin
          if Restart then _InternalFirst;
          Status := _InternalNext(true);
     end else
     begin
          if Restart then _InternalLast;
          Status := _InternalPrior(true);
     end;

     if Status then
     begin
          Resync([rmExact, rmCenter]);
          SetFound(True);
     end;
     Result := Found;
     if Result then DoAfterScroll;
end;

{$IFDEF LEVEL5}
// Free filter buffers.
procedure TkbmCustomMemTable.FreeFilter(var AFilterParser:TExprParser);
begin
     if Assigned(AFilterParser) then
     begin
          AFilterParser.free;
          AFilterParser:=nil;
     end;
end;

// Parse filterstring and build new filter.
// Filter operators supported:
// = < > <> <= >= AND OR NULL
// Field Operator Constant Eg: Field1>32 and Field2='ABC'
procedure TkbmCustomMemTable.BuildFilter(var AFilterParser:TExprParser; AFilter:string; AFilterOptions:TFilterOptions);
begin
     if AFilterParser<>nil then
     begin
          AFilterParser.free;
          AFilterParser:=nil;
     end;

     AFilter:=Trim(AFilter);
     if AFilter='' then exit;

     AFilterParser:=TExprParser.Create(self,AFilter,AFilterOptions,[poExtSyntax],'',nil,FldTypeMap);
end;

// Parse build filter.
function TkbmCustomMemTable.ParseFilter(FilterExpr:TExprParser):variant;

  function VIsNull(AVariant:Variant):Boolean;
  begin
       Result:=VarIsNull(AVariant) or VarIsEmpty(AVariant);
  end;
var
   //iVersion,iTotalSize,iNodes,iNodeStart:Word;
   iLiteralStart:Word;

{$WARNINGS OFF}
   function ParseNode(pfdStart,pfd:PChar):variant;
   var
      b:WordBool;
      i,z:integer;
      year,mon,day,hour,min,sec,msec:word;

      iClass:NODEClass;
      iOperator:TCANOperator;

      pArg1,pArg2:PChar;
      Arg1,Arg2:variant;
      tstr:string;

      //     FieldNo:integer;
      FieldName:String;
      DataType:TFieldType;
      DataOfs:integer;
      //     DataSize:integer;

      ts:TTimeStamp;
      dt:TDateTime;
      cdt:Comp;
      bcd:TBCD;
      cur:Currency;

      PartLength:word;
      IgnoreCase:word;
      S1,S2:string;
   type
      PDouble=^Double;
      PTimeStamp=^TTimeStamp;
      PComp=^Comp;
      PWordBool=^WordBool;
      PBCD=^TBCD;
   begin
        // Get node class.
        iClass:=NODEClass(PInteger(@pfd[0])^);
        iOperator:=TCANOperator(PInteger(@pfd[4])^);
        inc(pfd,CANHDRSIZE);

//        ShowMessage(Format('Class=%d, Operator=%d',[ord(iClass),ord(iOperator)]));

        // Check class.
        case iClass of
            nodeFIELD:
               begin
                    case iOperator of
                         coFIELD2:
                           begin
//                                FieldNo:=PWord(@pfd[0])^ - 1;
                                DataOfs:=iLiteralStart+PWord(@pfd[2])^;
                                pArg1:=pfdStart;
                                inc(pArg1,DataOfs);
                                FieldName:=String(pArg1);
                                Result:=FieldByName(FieldName).Value;
                           end;
                         else
                             raise EMemTableFilterError.CreateFmt(kbmUnknownOperator,[ord(iOperator)]);
                    end;
               end;

            nodeCONST:
               begin
                    case iOperator of
                         coCONST2:
                           begin
                                DataType:=TFieldType(PWord(@pfd[0])^);
                                // DataSize:=PWord(@pfd[2])^;
                                DataOfs:=iLiteralStart+PWord(@pfd[4])^;

                                pArg1:=pfdStart;
                                inc(pArg1,DataOfs);

                                // Check type.
                                Case DataType of
                                     ftSmallInt, ftWord: Result:=PWord(pArg1)^;
                                     ftInteger, ftAutoInc: Result:=PInteger(pArg1)^;
                                     ftFloat, ftCurrency: Result:=PDouble(pArg1)^;
{$IFDEF LEVEL5}
                                     ftGUID,
{$ENDIF}
                                     ftWideString: Result:=PWideString(pArg1)^;
                                     
                                     ftString,
                                     ftFixedChar: Result:=String(pArg1);
                                     ftDate:
                                       begin
                                            ts.Date:=PInteger(pArg1)^;
                                            ts.Time:=0;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ftTime:
                                       begin
                                            ts.Date:=0;
                                            ts.Time:=PInteger(pArg1)^;;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ftDateTime:
                                       begin
                                            cdt:=PDouble(pArg1)^;
                                            ts:=MSecsToTimeStamp(cdt);
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ftBoolean: Result:=PWordBool(pArg1)^;
{$IFDEF LEVEL6}
                                     ftTimeStamp: Result:=VarSQLTimeStampCreate(PSQLTimeStamp(pArg1)^);
{$ENDIF}
                                     ftBCD
{$IFDEF LEVEL6}
                                     ,ftFmtBCD
{$ENDIF}
                                     :
                                       begin
                                            bcd:=PBCD(pArg1)^;
                                            BCDToCurr(bcd,Cur);
                                            Result:=Cur;
                                       end;

                                     else
                                         raise EMemTableFilterError.CreateFmt(kbmUnknownFieldType,[ord(DataType)]);
                                end;
                           end;
                    end;
               end;

            nodeUNARY:
               begin
                    pArg1:=pfdStart;
                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);

                    case iOperator of
                         coISBLANK,coNOTBLANK:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                b:=VIsNull(Arg1);
                                if iOperator=coNOTBLANK then b:=not b;
                                Result:=Variant(b);
                           end;

                         coNOT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if VIsNull(Arg1) then
                                   Result:=Null
                                else
                                   Result:=Variant(not Arg1);
                           end;

                         coMINUS:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=-Arg1
                                else
                                    Result:=Null;
                           end;

                         coUPPER:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=UpperCase(Arg1)
                                else
                                    Result:=Null;
                           end;

                         coLOWER:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=LowerCase(Arg1)
                                else
                                    Result:=Null;
                           end;
                    end;
               end;

            nodeBINARY:
               begin
                    // Get Loper and Roper pointers to buffer.
                    pArg1:=pfdStart;
                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                    pArg2:=pfdStart;
                    inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^);

                    // Check operator for what to do.
                    case iOperator of
                         coEQ:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 = Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coNE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 <> Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coGT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 > Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coGE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 >= Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 < Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 <= Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coOR:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 or Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coAND:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 and Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coADD:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 + Arg2);
                                exit;
                           end;

                         coSUB:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 - Arg2);
                                exit;
                           end;

                         coMUL:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 * Arg2);
                                exit;
                           end;

                         coDIV:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 / Arg2);
                                exit;
                           end;

                         coMOD,coREM:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 mod Arg2);
                                exit;
                           end;

                         coIN:
                           begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then
                                begin
                                     Result:=false;
                                     exit;
                                end;

                                if VarIsArray(Arg2) then
                                begin
                                     b:=false;
                                     for i:=0 to VarArrayHighBound(Arg2,1) do
                                     begin
                                          if VarIsEmpty(Arg2[i]) then break;
                                          b:=(Arg1=Arg2[i]);
                                          if b then break;
                                     end;
                                end
                                else
                                    b:=(Arg1=Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLike:
                           begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then
                                begin
                                     Result:=false;
                                     exit;
                                end;
                                pArg1:=pChar(VarToStr(Arg1));
                                pArg2:=pChar(VarToStr(Arg2));
                                b:=MatchesMask(pArg1,pArg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         else
                             raise EMemTableFilterError.CreateFmt(kbmOperatorNotSupported,[ord(iOperator)]);
                    end;
               end;

            nodeCOMPARE:
               begin
                    IgnoreCase:=PWord(@pfd[0])^;
                    PartLength:=PWord(@pfd[2])^;
                    pArg1:=pfdStart+CANEXPRSIZE+PWord(@pfd[4])^;
                    pArg2:=pfdStart+CANEXPRSIZE+PWord(@pfd[6])^;
                    Arg1:=ParseNode(pfdStart,pArg1);
                    Arg2:=ParseNode(pfdStart,pArg2);
                    if VIsNull(Arg1) or VIsNull(Arg2) then
                    begin
                         Result:=false;
                         exit;
                    end;

                    S1:=Arg1;
                    S2:=Arg2;
                    if IgnoreCase=1 then
                    begin
                         S1:=AnsiUpperCase(S1);
                         S2:=AnsiUpperCase(S2);
                    end;
                    if PartLength>0 then
                    begin
                         S1:=Copy(S1,1,PartLength);
                         S2:=Copy(S2,1,PartLength);
                    end;

                    case iOperator of
                         coEQ:
                            begin
                                 b:=(S1 = S2);
                                 Result:=Variant(b);
                                 exit;
                            end;

                         coNE:
                            begin
                                 b:=(S1 <> S2);
                                 Result:=Variant(b);
                                 exit;
                            end;

                         coLIKE:
                            begin
                                 pArg1:=pChar(VarToStr(ParseNode(pfdStart,pArg1)));
                                 pArg2:=pChar(VarToStr(ParseNode(pfdStart,pArg2)));
                                 b:=MatchesMask(pArg1,pArg2);
                                 Result:=Variant(b);
                                 exit;
                            end;

                         else
                             raise EMemTableFilterError.CreateFmt(kbmOperatorNotSupported,[ord(iOperator)]);
                    end;
               end;

            nodeFUNC:
               begin
                    case iOperator of
                         coFUNC2:
                            begin
                                 pArg1:=pfdStart;
                                 inc(pArg1,iLiteralStart+PWord(@pfd[0])^);
                                 pArg1:=pChar(AnsiUpperCase(pArg1));  // Function name
                                 pArg2:=pfdStart;
                                 inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^); // Pointer to Value or Const

                                 if pArg1='UPPER' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=UpperCase(VarToStr(Arg2));
                                 end

                                 else if pArg1='LOWER' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=LowerCase(VarToStr(Arg2));
                                 end

                                 else if pArg1='SUBSTRING' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then
                                      begin
                                           Result:=Null;
                                           exit;
                                      end;

                                      Result:=Arg2;
                                      try
                                         pArg1:=pChar(VarToStr(Result[0]));
                                      except
                                         on EVariantError do // no Params for "SubString"
                                            raise EMemTableFilterError.CreateFmt(kbmInvMissParam,[pArg1]);
                                      end;

                                      i:=Result[1];
                                      z:=Result[2];
                                      if (z=0) then
                                      begin
                                           if (Pos(',',Result[1])>0) then  // "From" and "To" entered without space!
                                              z:=StrToInt(Copy(Result[1],Pos(',',Result[1])+1,Length(Result[1])))
                                           else                            // No "To" entered so use all
                                              z:=Length(pArg1);
                                      end;
                                      Result:=Copy(pArg1,i,z);
                                 end

                                 else if pArg1='TRIM' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=Trim(VarToStr(Arg2));
                                 end

                                 else if pArg1='TRIMLEFT' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=TrimLeft(VarToStr(Arg2));
                                 end

                                 else if pArg1='TRIMRIGHT' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=TrimRight(VarToStr(Arg2));
                                 end

                                 else if pArg1='GETDATE' then
                                    Result:=Now

                                 else if pArg1='YEAR' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=year;
                                      end;
                                 end


                                 else if pArg1='MONTH' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=mon;
                                      end;
                                 end

                                 else if pArg1='DAY' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=day;
                                      end;
                                 end

                                 else if pArg1='HOUR' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=hour;
                                      end;
                                 end

                                 else if pArg1='MINUTE' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=min;
                                      end;
                                 end

                                 else if pArg1='SECOND' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=sec;
                                      end;
                                 end

                                 else if pArg1='DATE' then  // Format DATE('datestring','formatstring')
                                 begin                      // or     DATE(datevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      if VarIsArray(Result) then
                                      begin
                                           try
                                              pArg1:=PChar(VarToStr(Result[0]));
                                              pArg2:=PChar(VarToStr(Result[1]));
                                           except
                                              on EVariantError do // no Params for DATE
                                                 raise EMemTableFilterError.CreateFmt(kbmInvMissParam,[pArg1]);
                                           end;

                                           tstr:=ShortDateFormat;
                                           try
                                              ShortDateFormat:=pArg2;
                                              Result:=StrToDate(pArg1);
                                           finally
                                              ShortDateFormat:=tstr;
                                           end;
                                      end
                                      else
                                          Result:=longint(trunc(VarToDateTime(Result)));
                                 end

                                 else if pArg1='TIME' then  // Format TIME('timestring','formatstring')
                                 begin                      // or     TIME(datetimevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      if VarIsArray(Result) then
                                      begin
                                           try
                                              pArg1:=PChar(VarToStr(Result[0]));
                                              pArg2:=PChar(VarToStr(Result[1]));
                                           except
                                              on EVariantError do // no Params for TIME
                                                 raise EMemTableFilterError.CreateFmt(kbmInvMissParam,[pArg1]);
                                           end;

                                           tstr:=ShortTimeFormat;
                                           try
                                              ShortTimeFormat:=pArg2;
                                              Result:=StrToTime(pArg1);
                                           finally
                                              ShortTimeFormat:=tstr;
                                           end;
                                      end
                                      else
                                          Result:=Frac(VarToDateTime(Result));
                                 end

                                 else
                                    raise EMemTableFilterError.CreateFmt(kbmInvFunction,[pArg1]);
                            end;
                         else
                            raise EMemTableFilterError.CreateFmt(kbmOperatorNotSupported,[ord(iOperator)]);
                    end;
               end;

            nodeLISTELEM:
               begin
                    case iOperator of
                         coLISTELEM2:
                            begin
                                 Result:=VarArrayCreate([0,50],VarVariant); // Create VarArray for ListElements Values
                                 i:=0;
                                 pArg1:=pfdStart;
                                 inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);

                                 repeat
                                       Arg1:=ParseNode(PfdStart,parg1);
                                       if VarIsArray(Arg1) then
                                       begin
                                            z:=0;
                                            while not VarIsEmpty(Arg1[z]) do
                                            begin
                                                 Result[i+z]:=Arg1[z];
                                                 inc(z);
                                            end;
                                       end
                                       else
                                          Result[i]:=Arg1;

                                       inc(i);
                                       pArg1:=pfdStart;
                                       inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);
                                 until NODEClass(PInteger(@pArg1[0])^)<>NodeListElem;

                                 // Only one or no Value so don't return as VarArray
                                 if i<2 then
                                 begin
                                      if VIsNull(Result[0]) then
                                         Result:=Null
                                      else
                                          Result:=VarAsType(Result[0],varString);
                                 end;
                            end;
                         else
                            raise EMemTableFilterError.CreateFmt(kbmOperatorNotSupported,[ord(iOperator)]);
                    end;
               end;
        else
            raise EMemTableFilterError.CreateFmt('iClass '+kbmOutOfRange,[ord(iClass)]);
        end;
   end;
{$WARNINGS ON}

var
   pfdStart,pfd:PChar;

begin
     pfdStart:=@FilterExpr.FilterData[0];
     pfd:=pfdStart;

     // Get header.
     //     iVersion:=PWord(@pfd[0])^;
     //     iTotalSize:=PWord(@pfd[2])^;
     //     iNodes:=PWord(@pfd[4])^;
     //     iNodeStart:=PWord(@pfd[6])^;
     iLiteralStart:=PWord(@pfd[8])^;
     inc(pfd,10);

     // Show header.
{
     ShowMessage(Format('Version=%d, TotalSize=%d, Nodes=%d, NodeStart=%d, LiteralStart=%d',
        [iVersion,iTotalSize,iNodes,iNodeStart,iLiteralStart]));

     s:='';
     for i:=0 to FFilterParser.DataSize-1 do
     begin
          b:=FFilterParser.FilterData[i];
          if (b>=32) and (b<=127) then s1:=chr(b)
          else s1:=' ';
          s:=s+Format('%d=%0.2x%s ',[i,FFilterParser.FilterData[i],s1]);
     end;
     ShowMessage(s);
}
     Result:=ParseNode(pfdStart,pfd);
end;

// Filter record according to filterexpression.
function TkbmCustomMemTable.FilterExpression(ARecord:PkbmRecord;AFilterParser:TExprParser):boolean;
var
   noderes:variant;
   oldrec:PkbmRecord;
begin
     oldrec:=FOverrideActiveRecordBuffer;
     try
        FOverrideActiveRecordBuffer:=ARecord;
        noderes:=ParseFilter(AFilterParser);
        Result:=(WordBool(noderes)=true);
     finally
        FOverrideActiveRecordBuffer:=oldrec;
     end;
//     ShowMessage(Format('noderes=%d Result=%d',[integer(noderes),ord(Result)]));
end;
{$ENDIF}

// Is any record filtering applied.
// Could be master/detail or userdefined filter.
procedure TkbmCustomMemTable.SetIsFiltered;
begin
     FCommon.Lock;
     try
        FIsFiltered:=(FStatusFilter<>[]) or
             ((FCommon.FDeletedCount>0) and not (usDeleted in FStatusFilter)) or
             (Filtered and ({$IFDEF LEVEL5}Assigned(FFilterParser) or {$ENDIF}Assigned(OnFilterRecord)))
             or (FMasterLinkUsed and Assigned(FMasterLink.DataSource) and (FMasterLink.FieldNames<>'') and ((FDetailIndexList.Count>0) or (FIndexList.Count>0)))
             or (FRangeActive);
     finally
        FCommon.Unlock;
     end;
end;

// Filter record according to master table.
function TkbmCustomMemTable.FilterMasterDetail(ARecord:PkbmRecord):boolean;
var
   aList:TkbmFieldList;
begin
     if (FDetailIndexList.Count<=0) then
        aList:=FIndexList
     else
         aList:=FDetailIndexList;
     Result:=FCommon._InternalCompareRecords(aList,FMasterLink.Fields.Count,FKeyBuffers[kbmkbMasterDetail],ARecord,false,false,chBreakNE)=0;
end;

// Filter record according to range.
function TkbmCustomMemTable.FilterRange(ARecord:PkbmRecord): Boolean;
begin
     Result:=(FCommon._InternalCompareRecords(FIndexList,-1,FKeyBuffers[kbmkbRangeStart],ARecord,FRangeIgnoreNullKeyValues,false,chBreakGT)<=0)
             and (FCommon._InternalCompareRecords(FIndexList,-1,FKeyBuffers[kbmkbRangeEnd],ARecord,FRangeIgnoreNullKeyValues,false,chBreakLT)>=0);
end;

// Filter records in general for
// master/detail, range and userdefined filter.
function TkbmCustomMemTable.FilterRecord(ARecord:PkbmRecord; ForceUseFilter:boolean): Boolean;
var
   SaveState: TDatasetState;
label
   L_Exit;
begin
     Result:=True;
     if not (ForceUseFilter or IsFiltered) then Exit;

     // Check if record is deleted, but versioning.
     if ((FStatusFilter<>[]) and not (ARecord^.UpdateStatus in FStatusFilter)) then
     begin
          Result:=False;
          exit;
     end;

     // Now we will apply the filters on the record.
     SaveState:=SetTempState(dsFilter);
     FFilterRecord:=ARecord;

     // Check if to recalc before compare.
     if FRecalcOnIndex then
     begin
          ClearCalcFields(PChar(ARecord));
          GetCalcFields(PChar(ARecord));
     end;

     // Check if range filtering.
     if FRangeActive then
     begin
          Result:=FilterRange(ARecord);
          if not Result then goto L_exit;
     end;

     // Check if master/detail filtering.
     if FMasterLinkUsed and Assigned(FMasterLink.DataSource) and (FMasterLink.FieldNames<>'') and ((FDetailIndexList.Count>0) or (FIndexList.Count>0)) then
     begin
          Result:=FilterMasterDetail(ARecord);
          if not Result then goto L_Exit;
     end;

     // Check filters.
     if ForceUseFilter or Filtered then
     begin
          // Call users own filtering if specified.
          DoOnFilterRecord(self,Result);
          if not Result then goto L_Exit;

{$IFDEF LEVEL5}
          // Check if filterstring active.
          if Assigned(FFilterParser) then
          begin
               Result:=FilterExpression(ARecord,FFilterParser);
               if not Result then goto L_exit;
          end;
{$ENDIF}
     end;

L_Exit:
     // Finished filtering.
     RestoreState(SaveState);
end;

{$IFDEF LEVEL5}
// Test an user filter against to the current record
function TkbmCustomMemTable.TestFilter(const AFilter:string; AFilterOptions:TFilterOptions):boolean;
var
   parser: TExprParser;
begin
     Result:=Active;
     if (AFilter='') or not Active then exit;
     parser:=nil;
     try
        BuildFilter(parser,AFilter,AFilterOptions);
        Result:=FilterExpression(GetActiveRecord,parser);
     finally
        if parser<>nil then FreeFilter(parser);
     end;
end;
{$ENDIF}

procedure TkbmCustomMemTable.InternalSetToRecord(Buffer: PChar);
var
   pb:PkbmRecord;
   pbUser:PkbmUserBookmark;
   pbmData:PkbmBookmark;
begin
     if Buffer=nil then exit;

     pbUser:=PkbmUserBookmark(@Buffer);
     pb:=pbUser^.Bookmark;
     if pb=nil then exit;
     if pb.RecordNo<>-1 then
     begin
          FRecNo:=pb.RecordNo;
          exit;
     end;

     // If record number not readily available search for it.
     pbmData:=PkbmBookmark(PkbmRecord(Buffer).Data+FCommon.FStartBookmarks);
     inc(pbmData,FTableID);
     InternalGotoBookmark(pbmData);
end;

function TkbmCustomMemTable.GetRecordCount: integer;
var
   SaveState: TDataSetState;
   SavePosition: integer;
   TempBuffer: PChar;
begin
     if not Active then DatabaseError(SDatasetClosed{$IFNDEF LEVEL3}, Self{$ENDIF});

     if not IsFiltered then Result:=FCurIndex.FReferences.Count
     else
     begin
          Result:=0;
          SaveState:=SetTempState(dsBrowse);
          SavePosition:=FRecNo;
          TempBuffer:=PChar(FCommon._InternalAllocRecord);
          try
             InternalFirst;
             while GetRecord(TempBuffer,gmNext,True)=grOk do Inc(Result);
          finally
             RestoreState(SaveState);
             FRecNo:=SavePosition;
             FCommon._InternalFreeRecord(PkbmRecord(TempBuffer),false,false);
          end;
     end;
end;

function TkbmCustomMemTable.GetRecNo: integer;
begin
     if (State=dsInactive) or (ActiveBuffer=nil) or IsEmpty or (PkbMRecord(ActiveBuffer)^.RecordNo<0) then Result:=-1
     else Result:=PkbmRecord(ActiveBuffer)^.RecordNo+1;
end;

procedure TkbmCustomMemTable.SetRecNo(Value: Integer);
var
   r:integer;
begin
     CheckActive;
     r:=GetRecNo; 
     if Value=r then exit;
     if (Value<1) or (Value>FCurIndex.FReferences.Count) then exit;

     if not IsFiltered then
     begin
          DoBeforeScroll;
          FRecNo:=Value-1;
          DoAfterScroll;
          Resync([]);
     end
     else
     begin
          MoveBy(Value-r);
     end;
     CursorPosChanged;
end;

procedure TkbmCustomMemTable.InternalAddRecord(Buffer: Pointer; Append: Boolean);
var
   pRec,pCopyRec:PkbmRecord;
   where:integer;
begin
     pRec:=PkbmRecord(Buffer);

     // Check record acceptance.
     Indexes.CheckRecordUniqueness(pRec,nil);

     // Copy the reference record.
     pCopyRec:=FCommon._InternalCopyRecord(pRec,true);

     // Update indexes and add physical record.
     where:=FRecNo;
     if Append then where:=-1;
     FCommon.ReflectToIndexes(self,mtiuhInsert,nil,pCopyRec,where,false);

     // Append the reference record.
     pCopyRec^.TransactionLevel:=TransactionLevel;
     pCopyRec^.Flag:=pCopyRec^.Flag or kbmrfInTable;
     IsDataModified:=true;

     FCommon._InternalAppendRecord(pCopyRec);
end;

procedure TkbmCustomMemTable.InternalDelete;
var
   pRec,pDelRec:PkbmRecord;
begin
     FCommon.Lock;
     try
        pRec:=PkbmRecord(FCurIndex.FReferences.Items[FRecNo]);

        // Update indexes.
        FCommon.ReflectToIndexes(self,mtiuhDelete,pRec,nil,FRecNo,false);

        // Check if versioning. Dont delete the record. Only mark it as so.
        if IsVersioning then
        begin
             pDelRec:=FCommon._InternalCopyRecord(pRec,true);
             pRec^.PrevRecordVersion:=pDelRec;
             pRec^.UpdateStatus:=usDeleted;
             pRec^.TransactionLevel:=TransactionLevel;
             inc(FCommon.FDeletedCount);
        end
        else
        begin
             FCommon._InternalDeleteRecord(pRec);

             // After deleted last record, reset state of the table to empty.
             if (FCommon.FRecords.Count=0) then FCommon._InternalEmpty;
        end;

//Removed Aug. 4. to solve grid reposition problem.        ClearBuffers;
        IsDataModified:=true;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.InternalInitRecord(Buffer: PChar);
begin
     // Clearout record contents.
     FCommon._InternalClearRecord(PkbmRecord(Buffer));
end;

procedure TkbmCustomMemTable.InternalPost;
var
   pActRec,pNewRec,pRec:PkbmRecord;
begin
{$IFDEF LEVEL6}
     inherited;    // Otherwise the requiredfieldscheck will not happen.
{$ENDIF}

     FCommon.Lock;
     try
        pActRec:=PkbmRecord(ActiveBuffer);

        if State = dsEdit then
        begin
             // Get reference to record to modify.
             pRec:=FCurIndex.FReferences[FRecNo];

             // Check that record does not violate index.
             Indexes.CheckRecordUniqueness(pActRec,pRec);

             // Check if to update version.
             if Modified then
             begin
                  pActRec^.UpdateStatus:=UsModified;
                  if IsVersioning then
                  begin
                       // Check if only to keep original record since checkpoint.
                       if (FCommon.FVersioningMode=mtvmAllSinceCheckPoint) or
                          ((FCommon.FVersioningMode=mtvm1SinceCheckPoint) and (pActRec^.PrevRecordVersion=nil)) then
                       begin
                            pActRec^.PrevRecordVersion:=FCommon._InternalCopyRecord(pRec,True);
                            pActRec^.PrevRecordVersion^.Flag:=pActRec^.PrevRecordVersion^.Flag or kbmrfInTable;
                       end;
                  end;
                  IsDataModified:=true;
             end;

             // Update index.
             FCommon.ReflectToIndexes(self,mtiuhEdit,pRec,pActRec,FRecNo,false);

             // Alter the physical record.
             FCommon._InternalTransferRecord(pActRec,pRec);
             pRec^.Flag:=pRec^.Flag or kbmrfInTable;
             pRec^.TransactionLevel:=TransactionLevel;
        end
        else  // dsInsert.
        begin
             // Check record acceptance.
             Indexes.CheckRecordUniqueness(pActRec,nil);

             // New record. Allocate room for it and copy the reference record.
             pNewRec:=FCommon._InternalCopyRecord(pActRec,true);
             FCommon._InternalFreeRecordVarLengths(pActRec);

             // Add the physical record.
             FCommon._InternalAppendRecord(pNewRec);
             pNewRec^.TransactionLevel:=TransactionLevel;
             pNewRec^.Flag:=pNewRec^.Flag or kbmrfInTable;

             // Add to index.
             // If BOF bookmark flag set, then append, dont insert.
             if GetBookmarkFlag(PChar(pNewRec))=bfEOF then
                FCommon.ReflectToIndexes(self,mtiuhInsert,nil,pNewRec,-1,false)
             else
                FCommon.ReflectToIndexes(self,mtiuhInsert,nil,pNewRec,FInsertRecNo,false);

             IsDataModified:=true;
        end;
        FCommon.ClearModifiedFlags;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.InternalEdit;
begin
     inherited InternalEdit;
end;

{$IFNDEF LEVEL3}
procedure TkbmCustomMemTable.InternalInsert;
begin
     inherited InternalInsert;
end;
{$ENDIF}

procedure TkbmCustomMemTable.InternalCancel;
begin
     inherited InternalCancel;
     FCommon.ClearModifiedFlags;
end;

// Bookmark handling.

procedure TkbmCustomMemTable.SetBookmarkFlag(Buffer:PChar; Value:TBookmarkFlag);
var
   pbmData:PkbmBookmark;
begin
     pbmData:=PkbmBookmark(PkbmRecord(Buffer).Data+FCommon.FStartBookmarks);
     inc(pbmData,FTableID);

     pbmData^.Flag:=Value;
end;

function TkbmCustomMemTable.GetBookmarkFlag(Buffer:PChar): TBookmarkFlag;
var
   pbmData:PkbmBookmark;
begin
     pbmData:=PkbmBookmark(PkbmRecord(Buffer).Data+FCommon.FStartBookmarks);
     inc(pbmData,FTableID);

     Result:=pbmData^.Flag;
end;

procedure TkbmCustomMemTable.GetBookmarkData(Buffer:PChar; Data:Pointer);
var
   pbmData:PkbmBookmark;
   pbmUser:PkbmUserBookmark;
begin
     pbmData:=PkbmBookmark(PkbmRecord(Buffer)^.Data+FCommon.FStartBookmarks);
     inc(pbmData,FTableID);

     pbmUser:=PkbmUserBookmark(Data);
     pbmUser^.Bookmark:=pbmData^.Bookmark;
     pbmUser^.DataID:=FCommon.FDataID;
end;

procedure TkbmCustomMemTable.SetBookmarkData(Buffer:PChar; Data:Pointer);
var
   pbmData:PkbmBookmark;
   pbmUser:PkbmUserBookmark;
begin
     pbmData:=PkbmBookmark(PkbmRecord(Buffer)^.Data+FCommon.FStartBookmarks);
     inc(pbmData,FTableID);

     pbmUser:=PkbmUserBookmark(Data);
     pbmData^.Bookmark:=pbmUser^.Bookmark;
end;

// Check if a bookmarkpointer is actually valid.
function TkbmCustomMemTable.InternalBookmarkValid(Bookmark:Pointer):boolean;
var
   p:PkbmRecord;
   pbmUser:PkbmUserBookmark;
begin
     Result:=Bookmark<>nil;
     if Result then
     begin
          pbmUser:=PkbmUserBookmark(Bookmark);
          Result:=(pbmUser<>nil) and (pbmUser^.DataID=FCommon.FDataID);
          if Result then
          begin
               p:=PkbmRecord(pbmUser^.Bookmark);
               Result:=(p<>nil) and (p^.Data<>nil);
          end;
     end;
end;

function TkbmCustomMemTable.BookmarkValid(Bookmark:TBookmark): boolean;
begin
     result:=InternalBookmarkValid(Bookmark);
end;

function TkbmCustomMemTable.CompareBookmarks(Bookmark1,Bookmark2:TBookmark): Integer;
const
     RetCodes: array[Boolean, Boolean] of ShortInt = ((2,-1),(1,0));
var
   pUser1,pUser2:PkbmUserBookmark;
   p1,p2:PkbmRecord;
begin
     // Check for invalid/uninitialized bookmarks
     if not (BookMarkValid(Bookmark1) and BookMarkValid(Bookmark2)) then
     begin
          Result:=0;
          exit;
     end;

     // Check contents of bookmark.
     pUser1:=PkbmUserBookmark(Bookmark1);
     pUser2:=PkbmUserBookmark(Bookmark2);
     p1:=pUser1^.Bookmark;
     p2:=pUser2^.Bookmark;

     // Compare record contents.
     FCommon.Lock;
     try
        if FCurIndex=FIndexes.FRowOrderIndex then
           Result:=p1^.RecordID - p2^.RecordID
        else
        begin
             Result:=FCurIndex.CompareRecords(FCurIndex.FIndexFieldList,p1,p2,true,false);
             if Result=0 then Result:=p1^.RecordNo-p2^.RecordNo;
             if Result=0 then Result:=p1^.RecordID-p2^.RecordID;
        end;
     finally
        FCommon.Unlock;
     end;

     // Convert to -1,0,1 range.
     if Result<0 then Result:=-1
     else if Result>0 then Result:=1;
end;

procedure TkbmCustomMemTable.InternalGotoBookmark(Bookmark:Pointer);
var
   i:integer;
   pb:PkbmRecord;
   pbUser:PkbmUserBookmark;
begin
     if Bookmark=nil then
        raise EMemTableError.CreateFmt(kbmBookmErr,[-200]);

     pbUser:=PkbmUserBookmark(Bookmark);
     pb:=pbUser^.Bookmark;

     if pb=nil then exit;
     FCommon.Lock;
     try
        FCurIndex.SearchRecord(pb,i,true);
        if (i>=0) then FRecNo:=i;
     finally
        FCommon.Unlock;
     end;
end;

procedure TkbmCustomMemTable.InternalHandleException;
begin
{$IFDEF CLX}
     if Assigned(Classes.ApplicationHandleException) then
        Classes.ApplicationHandleException(Self);
{$ELSE}
     Application.HandleException(Self);
{$ENDIF}
end;

procedure TkbmCustomMemTable.SaveToFileViaFormat(const FileName:string; AFormat:TkbmCustomStreamFormat);
var
   Stream: TStream;
begin
     CheckActive;
     if not Assigned(AFormat) then
        raise EMemTableError.Create(kbmNoFormat);

     if (sfSaveAppend in AFormat.sfAppend) and FileExists(FileName) then
     begin
          Stream := TFileStream.Create(FileName,fmOpenReadWrite + fmShareDenyWrite);
          Stream.Seek(0,soFromEnd);
     end
     else
         Stream := TFileStream.Create(FileName,fmCreate);
     try
        if (assigned(FOnSave)) then FOnSave(self,mtstFile,Stream);
        InternalSaveToStreamViaFormat(Stream,AFormat);
     finally
        Stream.Free;
     end;
end;

procedure TkbmCustomMemTable.SaveToFile(const FileName:string);
begin
     SaveToFileViaFormat(FileName,FDefaultFormat);
end;

procedure TkbmCustomMemTable.SaveToStreamViaFormat(Stream:TStream; AFormat:TkbmCustomStreamFormat);
begin
     CheckActive;
     if (assigned(FOnSave)) then FOnSave(self,mtstStream,Stream);
     InternalSaveToStreamViaFormat(Stream,AFormat);
end;

procedure TkbmCustomMemTable.SaveToStream(Stream:TStream);
begin
     SaveToStreamViaFormat(Stream,FDefaultFormat);
end;

procedure TkbmCustomMemTable.CloseBlob(Field:TField);
var
   pField:PChar;
   pBlob:PPkbmVarLength;
begin
     if (FRecNo<0) or (FRecNo>=FCurIndex.FReferences.Count) or (not (State in [dsEdit,dsInactive])) then
     begin
          if Field.DataType in kbmBlobTypes then
          begin
               pField:=FCommon.GetFieldPointer(PkbmRecord(ActiveBuffer),Field);
               pBlob:=PPkbmVarLength(pField+1);
               pField[0]:=kbmffNull;
               pBlob^:=nil;
          end;
     end;
end;

procedure TkbmCustomMemTable.InternalSaveToStreamViaFormat(AStream:TStream; AFormat:TkbmCustomStreamFormat);
begin
     if not Assigned(AFormat) then raise EMemTableError.Create(kbmNoFormat);

     with AFormat do
     begin
          FOrigStream:=AStream;
          FWorkStream:=nil;
          try
             BeforeSave(self);
             try
                Save(self);
             finally
                AfterSave(self);
             end;
          finally
             FWorkStream:=nil;
             FOrigStream:=nil;
          end;
     end;
end;

procedure TkbmCustomMemTable.InternalLoadFromStreamViaFormat(AStream:TStream; AFormat:TkbmCustomStreamFormat);
begin
     if not Assigned(AFormat) then raise EMemTableError.Create(kbmNoFormat);

     with AFormat do
     begin
          FOrigStream:=AStream;
          FWorkStream:=nil;
          try
             BeforeLoad(self);
             Load(self);
          finally
             AfterLoad(self);
             FOrigStream:=nil;
             FWorkStream:=nil;
          end;
     end;
end;

procedure TkbmCustomMemTable.LoadFromFileViaFormat(const FileName: string; AFormat:TkbmCustomStreamFormat);
var
   Stream: TStream;
begin
     Stream := TFileStream.Create(FileName, fmOpenRead+fmShareDenyWrite);
     try
        if assigned(FOnLoad) then FOnLoad(self,mtstFile,Stream);
        InternalLoadFromStreamViaFormat(Stream,AFormat);
     finally
        Stream.Free;
     end;
end;

procedure TkbmCustomMemTable.LoadFromFile(const FileName:string);
begin
     LoadFromFileViaFormat(FileName,FDefaultFormat);
end;

procedure TkbmCustomMemTable.LoadFromStreamViaFormat(Stream:TStream; AFormat:TkbmCustomStreamFormat);
begin
     if assigned(FOnLoad) then FOnLoad(self,mtstStream,Stream);
     InternalLoadFromStreamViaFormat(Stream,AFormat);
end;

procedure TkbmCustomMemTable.LoadFromStream(Stream:TStream);
begin
     if assigned(FOnLoad) then FOnLoad(self,mtstStream,Stream);
     InternalLoadFromStreamViaFormat(Stream,FDefaultFormat);
end;

procedure TkbmCustomMemTable.InternalEmptyTable;
var
   OldState:TkbmState;
begin
     OldState:=FState;
     FState:=mtstEmpty;
     try
        CheckBrowseMode;
        ClearBuffers;
        DataEvent(deDataSetChange, 0);
        FIndexes.EmptyAll;
        FRecNo:=-1;
     finally
        FState:=OldState;
     end;
end;

procedure TkbmCustomMemTable.EmptyTable;
begin
     Progress(0,mtpcEmpty);
     DisableControls;
     try
        FCommon.EmptyTables;
     finally
        EnableControls;
        Progress(100,mtpcEmpty);
     end;
end;

procedure TkbmCustomMemTable.PackTable;
begin
     Cancel;
     Commit;
     CheckPoint;
     Progress(0,mtpcPack);
     FState:=mtstPack;
     DisableControls;
     try
        ClearBuffers;
        FCommon._InternalPackRecords;
        First;
     finally
        EnableControls;
        Progress(100,mtpcPack);
        FState:=mtstBrowse;
     end;
end;

// Checkpoint a single record.
// Throws away old version records, and actually removes delete marked records.
procedure TkbmCustomMemTable.CheckPointRecord(RecordIndex:integer);
var
   ARecord:PkbmRecord;
begin
     ARecord:=FCommon.FRecords.Items[RecordIndex];
     if ARecord=nil then exit;

     // Check if allow to checkpoint.
     if (ARecord^.Flag and kbmrfDontCheckPoint)=kbmrfDontCheckPoint then exit;

     // Check if versioning data, remove them.
     if ARecord^.PrevRecordVersion<>nil then
     begin
          FCommon._InternalFreeRecord(ARecord^.PrevRecordVersion,true,true);
          ARecord^.PrevRecordVersion:=nil
     end;

     // Check if deleted record, delete it real this time.
     if ARecord^.UpdateStatus=usDeleted then
     begin
          FCommon.ReflectToIndexes(self,mtiuhDelete,ARecord,nil,RecordIndex,false);
          FCommon._InternalDeleteRecord(ARecord);
     end
     else
     begin
          // Reset status flags.
          ARecord^.UpdateStatus:=usUnModified;
          ARecord^.Flag:=ARecord^.Flag and (not kbmrfDontCheckPoint);
     end;
end;

// Define checkpoint for versioning.
// Throws away old version records, and actually removes delete marked records.
procedure TkbmCustomMemTable.CheckPoint;
var
   i:integer;
   oEnableVersioning:boolean;
   ProgressCnt:integer;
begin
     if FAttachedTo<>nil then raise EMemTableError.Create(kbmCantCheckpointAttached);
     UpdateCursorPos;

     // Make sure operations are really happening and not just versioned.
     Progress(0,mtpcCheckPoint);
     ProgressCnt:=0;
     FCommon.Lock;
     try
        oEnableVersioning:=FCommon.FEnableVersioning;
        FCommon.FEnableVersioning:=false;
        FState:=mtstCheckPoint;
        ClearBuffers;
        for i:=FCommon.FRecords.Count-1 downto 0 do
        begin
             inc(ProgressCnt);
             ProgressCnt:=ProgressCnt mod 100;
             if ProgressCnt=0 then Progress(trunc(i/FCommon.FRecords.Count * 100),mtpcCheckPoint);

             CheckpointRecord(i);
        end;

        FCommon.FDeletedCount:=0;
        FCommon.FEnableVersioning:=oEnableVersioning;
     finally
        FCommon.Unlock;
        First;
        Progress(100,mtpcCheckPoint);
        FState:=mtstBrowse;
     end;
end;

procedure TkbmCustomMemTable.SetCommaText(AString: String);
var
   stream:TMemoryStream;
begin
     EmptyTable;
     stream:=TMemoryStream.Create;
     try
        stream.Write(Pointer(AString)^,length(AString));
        stream.Seek(0,soFromBeginning);
        LoadFromStreamViaFormat(stream,FCommaTextFormat);
     finally
        stream.free;
     end;
end;

function TkbmCustomMemTable.GetCommaText: String;
var
   stream:TMemoryStream;
   sz:integer;
   p:PChar;
begin
     Result:='';
     stream:=TMemoryStream.Create;
     try
        SaveToStreamViaFormat(stream,FCommaTextFormat);
        stream.Seek(0,soFromBeginning);
        sz:=stream.Size;
        p:=stream.Memory;
        setstring(Result,p,sz);
     finally
        stream.free;
     end;
end;

// Save persistent table.
procedure TkbmCustomMemTable.SavePersistent;
var
   TempFile:string;
   BackupFile : String;
begin
     if not Active then exit;
     
     // If persistent, save info to file.
     if (not FPersistentSaved) and (not (csDesigning in ComponentState))
        and FPersistent and (FPersistentFile <> '') and (FPersistentFormat<>nil) then
     begin
          TempFile:=ChangeFileExt(FPersistentFile, '.$$$');
          SaveToFileViaFormat(TempFile,FPersistentFormat);
          if FPersistentBackup then
          begin
               BackupFile := ChangeFileExt(FPersistentFile, FPersistentBackupExt);
               SysUtils.DeleteFile(BackupFile);
               SysUtils.RenameFile(FPersistentFile, BackupFile);
          end
          else
              SysUtils.DeleteFile(FPersistentFile);
          SysUtils.RenameFile(TempFile,FPersistentFile);
          FPersistentSaved:=true;
     end;
end;

// Check if persistent file exists... ala does the table exist in storage.
function TkbmCustomMemTable.Exists:boolean;
begin
     Result:=FileExists(FPersistentFile);
end;

// Load persistent table.
procedure TkbmCustomMemTable.LoadPersistent;
begin
     if FPersistent and (FPersistentFile <> '') and FileExists(FPersistentFile) then
     begin
          FPersistent:=false;
          try
             LoadFromFileViaFormat(FPersistentFile,FPersistentFormat);
             first;
          finally
             FPersistent:=true;
          end;
     end;
     FPersistentSaved:=false;
end;

// Sneak in before the table is closed.
procedure TkbmCustomMemTable.DoBeforeClose;
begin
     // Check if not in browse mode.
     if (State in [dsEdit,dsInsert]) then Cancel;

     if not FBeforeCloseCalled then inherited;
//     SavePersistent;
     FBeforeCloseCalled:=true;
end;

// Sneak in before the table is opened.
procedure TkbmCustomMemTable.DoBeforeOpen;
begin
     inherited;
end;

// Sneak in after the table is opened.
procedure TkbmCustomMemTable.DoAfterOpen;
begin
     // DoAfterOpen is not reentrant. Thus prevent that situation.
     if FDuringAfterOpen then exit;

     FDuringAfterOpen:=true;
     try
        Indexes.MarkAllDirty;
        UpdateIndexes;

        // Switch index.
        if FIndexFieldNames<>'' then
           SetIndexFieldNames(FIndexFieldNames)
        else if FIndexName<>'' then
           SetIndexName(FIndexName);

        // If to load data from form, do it.
        if FTempDataStorage<>nil then
        begin
             if FStoreDataOnForm then LoadFromStreamViaFormat(FTempDataStorage,FFormFormat);
             FTempDataStorage.free;
             FTempDataStorage:=nil;
        end;

        // If persistent, read info from file.
        LoadPersistent;

{$IFDEF LEVEL5}
        // If filtering, build filter.
        if Filter<>'' then BuildFilter(FFilterParser,Filter,FFilterOptions);
{$ENDIF}
        SetIsFiltered;

        inherited;
     finally
        FDuringAfterOpen:=false;
        if FAutoUpdateFieldVariables then UpdateFieldVariables;
     end;
end;

// Sneak in after a post to update attached tables.
procedure TkbmCustomMemTable.DoAfterPost;
begin
     if FAttachedAutoRefresh then
        FCommon.RefreshTables(Self);

     // Check if to reposition.
     if FAutoReposition and (FReposRecNo>=0) then
     begin
          FRecNo:=FReposRecNo;
          FReposRecNo:=-1;
          Resync([]);
     end;
     
     inherited;
end;

// Sneak in after a delete to update attached tables.
procedure TkbmCustomMemTable.DoAfterDelete;
begin
     if FAttachedAutoRefresh then
        FCommon.RefreshTables(self);

     FReposRecNo:=-1; // Nothing to reposition to.
     inherited;
end;

// Locate record.
// If the keyfields are the same as sorted fields and the table is currently sorted,
// it will make a fast binary search. Otherwise it will make a sequential search.
// Binary searches dont take partial record in account.
function TkbmCustomMemTable.LocateRecord(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions):Integer;
var
   KeyFieldsList:TkbmFieldList;
   KeyRecord:PkbmRecord;
   i:integer;
   Index:integer;
   Found:boolean;
begin
     Result := -1;
     I := VarArrayDimCount(KeyValues);
     if I > 1 then
        raise EMemTableError.Create(kbmVarArrayErr);

     CheckBrowseMode;
     CursorPosChanged;

     // Prepare list of fields representing the keys to search for.
     KeyFieldsList := TkbmFieldList.Create;
     try
        BuildFieldList(self,KeyFieldsList, KeyFields);

        // Setup key options.
        if loCaseInsensitive in Options then SetFieldListOptions(KeyFieldsList,mtifoCaseInsensitive,KeyFields);
        if loPartialKey in Options then SetFieldListOptions(KeyFieldsList,mtifoPartial,KeyFields);

        // Populate a keyrecord.
        KeyRecord:=FCommon._InternalAllocRecord;
        try
           // Fill it with values.
           PopulateRecord(KeyRecord,KeyFields,KeyValues);

           // Locate record.
           Index:=-1;
           Indexes.Search(KeyFieldsList,KeyRecord,false,true,FAutoAddIndexes,Index,Found);
           if Found then
              Result:=Index;

        finally
           // Free reference record.
           FCommon._InternalFreeRecord(KeyRecord,true,false);
        end;

     finally
        KeyFieldsList.Free;
     end;
end;

function TkbmCustomMemTable.Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant;
var
   n:integer;
begin
     Result := Null;
     n:=LocateRecord(KeyFields, KeyValues, []);
     SetFound(n>=0);
     if n>=0 then
     begin
          SetTempState(dsCalcFields);
          try
             CalculateFields(PChar(FCurIndex.FReferences[n]));
             Result := FieldValues[ResultFields];
          finally
             RestoreState(dsBrowse);
          end;
     end;
end;

function TkbmCustomMemTable.LookupByIndex(const IndexName:string; const KeyValues:Variant;
                                          const ResultFields:string; RespFilter:boolean):Variant;
var
   i:integer;
   idx:TkbmIndex;
   KeyFieldsList:TkbmFieldList;
   KeyRecord:PkbmRecord;
   f:boolean;
begin
     Result:=null;
     idx:=GetIndexByName(IndexName);
     if idx=nil then exit;

     if VarArrayDimCount(KeyValues)>1 then
        raise EMemTableError.Create(kbmVarArrayErr);

     CheckBrowseMode;
     CursorPosChanged;

     // Prepare list of fields representing the keys to search for.
     KeyFieldsList := TkbmFieldList.Create;
     try
        BuildFieldList(self, KeyFieldsList, idx.IndexFields);

        // Populate a keyrecord.
        KeyRecord := FCommon._InternalAllocRecord;
        try
           // Fill it with values.
           PopulateRecord(KeyRecord,idx.IndexFields,KeyValues);

           // Locate record.
           i:=-1;
           if not((idx.Search(KeyFieldsList,KeyRecord,false,RespFilter,i,f)=0) and (i>=0)) then
              i:=-1;
        finally
           // Free reference record.
           FCommon._InternalFreeRecord(KeyRecord,true,false);
     end;
     finally
        KeyFieldsList.Free;
     end;

     SetFound(f);
     if f then
     begin
          SetTempState(dsCalcFields);
          try
             CalculateFields(PChar(idx.FReferences[i]));
             Result:=FieldValues[ResultFields];
          finally
             RestoreState(dsBrowse);
          end;
     end;
end;

function TkbmCustomMemTable.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
   n:integer;
begin
     DoBeforeScroll;
     n:=LocateRecord(KeyFields, KeyValues, Options);
     Result:=(n>=0);
     SetFound(Result);
     if n>=0 then
     begin
          FRecNo:=n;
          Resync([rmExact, rmCenter]);
          DoAfterScroll;
     end;
end;

// Copy properties from one field to another.
procedure TkbmCustomMemTable.CopyFieldProperties(Source,Destination:TField);
begin
     // Did we get valid parameters.
     if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

     // Copy general properties.
     with Source do
     begin
          Destination.EditMask:=EditMask;
          Destination.DisplayWidth:=DisplayWidth;
          Destination.DisplayLabel:=DisplayLabel;
          Destination.Required:=Required;
          Destination.ReadOnly:=ReadOnly;
          Destination.Visible:=Visible;
          Destination.DefaultExpression:=DefaultExpression;
          Destination.Alignment:=Alignment;
{$IFDEF LEVEL5}
          Destination.ProviderFlags:=ProviderFlags;
{$ENDIF}
     end;

     // Copy field type specific properties.
     if Source is TNumericField then
        with TNumericField(Source) do
        begin
             TNumericField(Destination).DisplayFormat:=DisplayFormat;
             TNumericField(Destination).EditFormat:=EditFormat;
        end;

     if Source is TIntegerField then
        with TIntegerField(Source) do
        begin
             TIntegerField(Destination).MaxValue:=MaxValue;
             TIntegerField(Destination).MinValue:=MinValue;
        end;

     if Source is TDateTimeField then
        with TDateTimeField(Source) do
             TDateTimeField(Destination).DisplayFormat:=DisplayFormat;

     if Source is TBooleanField then
        with TBooleanField(Source) do
             TBooleanField(Destination).DisplayValues:=DisplayValues;

     if Source is TStringField then
        with TStringField(Source) do
             TStringField(Destination).Transliterate:=Transliterate;

     if Source is TFloatField then
        with TFloatField(Source) do
        begin
             TFloatField(Destination).MaxValue:=MaxValue;
             TFloatField(Destination).MinValue:=MinValue;
             TFloatField(Destination).Precision:=Precision;
             TFloatField(Destination).currency:=currency;
        end;

     if Source is TBCDField then
        with TBCDField(Source) do
        begin
             TBCDField(Destination).MaxValue:=MaxValue;
             TBCDField(Destination).MinValue:=MinValue;
             TBCDField(Destination).currency:=currency;
        end;

     if Source is TBlobField then
        with TBlobField(Source) do
        begin
             TBlobField(Destination).BlobType:=BlobType;
             TBlobField(Destination).Transliterate:=Transliterate;
        end;

     // Call eventhandler if needed.
     if Assigned(FOnSetupFieldProperties) then FOnSetupFieldProperties(self,Destination);
end;

// Copy properties from source to destination.
// Handles different fieldorder between the two datasets.
procedure TkbmCustomMemTable.CopyFieldsProperties(Source,Destination:TDataSet);
var
   i:integer;
   fc:integer;
   f:TField;
begin
     // Did we get valid parameters.
     if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

     // Copy constraints from source to destination.
     fc:=Destination.FieldCount-1;
     for i:=0 to fc do
     begin
          // Find matching fieldnames on both sides. If fieldname not found, dont copy it.
          f:=Source.FindField(Destination.Fields[i].FieldName);
          if f=nil then continue;
          CopyFieldProperties(f, Fields[i]);
     end;
end;

// Copy records from source to destination.
// Handles different fieldorder between the two datasets.
// Returns the number of records copied.
function TkbmCustomMemTable.CopyRecords(Source,Destination:TDataSet;Count:longint; IgnoreErrors:boolean{$IFDEF LEVEL6}; WideStringAsUTF8:boolean{$ENDIF}):longint;
var
   i:integer;
   fc:integer;
   f:TField;
   fsrc,fdst:TField;
   fi:array [0..KBM_MAX_FIELDS-1] of integer;
   Accept:boolean;
   RecCnt:integer;
   ProgressCnt:integer;
   cpAutoInc:boolean;
begin
     Result:=0;

     // Did we get valid parameters.
     if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

     // Build name index relations between destination and source dataset.
     fc:=Destination.FieldCount-1;
     Progress(0,mtpcCopy);
     for i:=0 to fc do
     begin
          // Check if not a datafield or not a supported field, dont copy it.
          case Destination.Fields[i].FieldKind of
               fkLookup: fi[i]:=-2; // Dont copy, dont clearout.
               fkData,fkInternalCalc,fkCalculated:
                 begin
                      // If unknown datatype, dont copy, just leave untouched.
                      if not (Destination.Fields[i].DataType in (kbmSupportedFieldTypes)) then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;

                      // Check if to copy autoinc from source.
                      if Destination.Fields[i].DataType=ftAutoInc then
                      begin
                           cpAutoInc:=Destination.isEmpty;
                           if not cpAutoInc then
                           begin
                                fi[i]:=-1;
                                continue;
                           end;
                      end;

                      // Find matching fieldnames on both sides. If fieldname not found, dont copy it, just clearout.
                      f:=Source.FindField(Destination.Fields[i].FieldName);
                      if f=nil then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;

{ Commented out to allow copying non datafields.
                      // If not a datafield just clearout.
                      if f.FieldKind<>fkData then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;
}

                      // Else copy the field.
                      fi[i]:=f.Index;
                 end;
          else
              // Other fieldkind, dont copy, just clearout.
              fi[i]:=-1;
          end;
     end;

     // Check number of records in source.
     if Assigned(FOnProgress) then
     begin
          RecCnt:=Source.RecordCount;
          if (RecCnt<=0) then Progress(50,mtpcCopy);
     end
     else RecCnt:=-1;

     // Copy data.
     FLoadedCompletely:=true;
     if (RecCnt<=0) then Progress(50,mtpcCopy);
     ProgressCnt:=0;
     while not Source.EOF do
     begin
          // Update progress.
          if (RecCnt>0) then
          begin
               inc(ProgressCnt);
               if (ProgressCnt mod 100)=0 then Progress(trunc(ProgressCnt/RecCnt*100),mtpcCopy);
          end;

          // Check acceptance of record.
          Accept:=true;
          if Assigned(FOnSaveRecord) and (Source=self) then FOnSaveRecord(Self,Accept);
          if not Accept then
          begin
               Source.Next;
               continue;
          end;

          Destination.Append;
          for i:=0 to fc do
          begin
               try
                  if fi[i]>=0 then
                  begin
                       fsrc:=Source.Fields[fi[i]];
                       fdst:=Destination.Fields[i];

                       if Assigned(FOnSaveField) and (Source=self) then FOnSaveField(Self,i,fsrc);

                       if fsrc.IsNull then
                          fdst.Clear
                       else
{$IFDEF LEVEL5}
                       if fsrc.DataType=ftLargeint then
                          fdst.AsString:=fsrc.AsString

                       // Check if to do automatic UTF8 conversion.
                       else if WideStringAsUTF8 and ((fsrc.DataType=ftWideString) or (fdst.DataType=ftWideString)) then
                       begin
                            if fsrc.DataType=fdst.DataType then
                               fdst.Value:=fsrc.Value
                            else if fsrc.DataType in [ftString,ftFixedChar] then
                               fdst.Value:=UTF8Decode(fsrc.AsString)
                            else if fdst.DataType in [ftString,ftFixedChar] then
                               fdst.AsString:=UTF8Encode(fsrc.Value)
                            else
                               fdst.Value:=fsrc.Value;
                       end

                       // Special error handling for ftOraClob and ftOraBlob fields
                       else if ((fsrc is TBlobField) and (TBlobField(fsrc).BlobType in [ftOraClob,ftOraBlob])) then
                       begin
                            try
                               fdst.AsString:=fsrc.AsString;
                            except
                               on E: Exception do
                               begin
                                 // swallow the BDE error, check classname not to import BDE classes.
                                 if E.ClassName='EDBEngineError' then
                                    // ***IMPACT ALERT***
                                    // this leaves the field defined but empty this breaks previous
                                    // functionality where this and subsequent fields just weren't
                                    // defined at all
                                    fdst.Clear
                                 else
                                    raise E;
                               end;
                            end
                       end
                       else
{$ENDIF}
                       if fsrc.ClassType<>fdst.ClassType then
                          fdst.AsString:=fsrc.AsString
                       else
                          fdst.Value:=fsrc.Value;
                       if Assigned(FOnLoadField) and (Destination=self) then FOnLoadField(Self,i,fdst);
                  end;
               except
                  if not IgnoreErrors then raise;
               end;
          end;

          Accept:=true;
          if Assigned(FOnLoadRecord) and (Destination=self) then FOnLoadRecord(Self,Accept);
          if Accept then
          begin
               try
                  Destination.Post;
               except
                  if not IgnoreErrors then raise;
               end;
               inc(Result);
               if (Count>0) and (Result>=Count) then
               begin
                    FLoadedCompletely:=Source.EOF;
                    break;
               end;
          end
          else Destination.Cancel;

          Source.next;
     end;
     Progress(100,mtpcCopy);
end;

// Assign the contents of active record in source to active record in destination.
// Handles different fieldorder between the two datasets.
procedure TkbmCustomMemTable.AssignRecord(Source,Destination:TDataSet);
var
   i:integer;
   fc:integer;
   f:TField;
   fi:array [0..KBM_MAX_FIELDS-1] of integer;
   Accept:boolean;
begin
     // Did we get valid parameters.
     if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

     // Build name index relations between destination and source dataset.
     fc:=Destination.FieldCount-1;
     Progress(0,mtpcCopy);
     for i:=0 to fc do
     begin
          // Check if not a datafield or not a supported field, dont copy it.
          case Destination.Fields[i].FieldKind of
               fkLookup: fi[i]:=-2; // Dont copy, dont clearout.
               fkData,fkInternalCalc,fkCalculated:
                 begin
                      // If unknown datatype or autoinc field, dont copy, just leave untouched.
                      if not (Destination.Fields[i].DataType in (kbmSupportedFieldTypes)) then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;

                      // Find matching fieldnames on both sides. If fieldname not found, dont copy it, just clearout.
                      f:=Source.FindField(Destination.Fields[i].FieldName);
                      if f=nil then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;

{ Commented out to allow copying non datafields.
                      // If not a datafield just clearout.
                      if f.FieldKind<>fkData then
                      begin
                           fi[i]:=-1;
                           continue;
                      end;
}

                      // Else copy the field.
                      fi[i]:=f.Index;
                 end;
          else
              // Other fieldkind, dont copy, just clearout.
              fi[i]:=-1;
          end;
     end;

     // Determine if to copy.
     Accept:=true;
     if Assigned(FOnSaveRecord) and (Source=self) then FOnSaveRecord(Self,Accept);
     if not Accept then exit;

     // Copy data.
     Destination.Edit;
     for i:=0 to fc do
     begin
          if Assigned(FOnSaveField) and (Source=self) then FOnSaveField(Self,i,Source.Fields[i]);
          if fi[i]>=0 then
          begin
               if Source.Fields[fi[i]].IsNull then
                  Destination.Fields[i].Clear
               else
                  Destination.Fields[i].AsString:=Source.Fields[fi[i]].AsString;
          end;
          if Assigned(FOnLoadField) and (Destination=self) then FOnLoadField(Self,i,Destination.Fields[i]);
     end;

     // Determine if to post.
     if Assigned(FOnLoadRecord) and (Destination=self) then FOnLoadRecord(Self,Accept);
     if Accept then Destination.post
     else Destination.Cancel;

     Progress(100,mtpcCopy);
end;

// Update destination with records not matching or existing in source.
function TkbmCustomMemTable.UpdateRecords(Source,Destination:TDataSet; KeyFields:string; Count:Integer; Flags:TkbmMemTableUpdateFlags): longint;
var
   i:integer;
   fc:integer;
   f:TField;
   fi:array [0..KBM_MAX_FIELDS-1] of integer;
   Accept,DoUpdate:boolean;
   KeyValues:Variant;
   KeyFieldsList:TkbmFieldList;
   RecCnt:integer;
   ProgressCnt:integer;
begin
     Progress(0,mtpcUpdate);
     FState:=mtstUpdate;
     KeyFieldsList := TkbmFieldList.Create;
     try
        BuildFieldList(self,KeyFieldsList, KeyFields);
        if KeyFieldsList.Count > 1 then
           KeyValues:=VarArrayCreate([0, KeyFieldsList.Count-1 ], varVariant);
        Result:=0;

        // Did we get valid parameters.
        if (Source=nil) or (Destination=nil) or (Source=Destination) then exit;

        // Build name index relations between destination and source dataset.
        fc:=Destination.FieldCount-1;
        for i:=0 to fc do
        begin
             // Check if not a datafield or not a supported field, dont copy it.
             case Destination.Fields[i].FieldKind of
                  fkLookup: fi[i]:=-2; // Dont copy, dont clearout.
                  fkData,fkInternalCalc,fkCalculated:
                    begin
                         // If unknown datatype, dont copy, just clearout.
                         if not (Destination.Fields[i].DataType in (kbmSupportedFieldTypes)) then
                         begin
                              fi[i]:=-1;
                              continue;
                         end;

                         // Find matching fieldnames on both sides. If fieldname not found, dont copy it, just clearout.
                         f:=Source.FindField(Destination.Fields[i].FieldName);
                         if f=nil then
                         begin
                              fi[i]:=-1;
                              continue;
                         end;

                         // Else copy the field.
                         fi[i]:=f.Index;
                    end;
             else
                 // Other fieldkind, dont copy, just clearout.
                 fi[i]:=-1;
             end;

             // Check if not to clear out afterall.
             if (mtufDontClear in Flags) and (fi[i]=-1) then fi[i]:=-2;
        end;

        // Copy data.
        Source.First;
        RecCnt:=Source.RecordCount;
        if (RecCnt<=0) then Progress(50,mtpcCopy);
        ProgressCnt:=0;
        while not Source.EOF do
        begin
             // Update progress.
             if (RecCnt>0) then
             begin
                  inc(ProgressCnt);
                  if (ProgressCnt mod 100)=0 then Progress(trunc(ProgressCnt/RecCnt*100),mtpcCopy);
             end;

             Accept:=true;
             if Assigned(FOnSaveRecord) and (Source=self) then FOnSaveRecord(Self,Accept);
             if not Accept then
             begin
                  Source.Next;
                  continue;
             end;

             // Convert variant array of values to a list of values.
             if KeyFieldsList.Count > 1 then
             begin
                  for i:=0 to KeyFieldsList.count-1 do
                      KeyValues[i]:=KeyFieldsList.Fields[i].AsVariant;
             end
             else
                 KeyValues:=KeyFieldsList.Fields[0].AsVariant;

             // Look for record in dest. dataset to determine if to append or update record.
             DoUpdate:=true;
             if not Destination.Locate(KeyFields,KeyValues,[]) then
             begin
                  if (mtufAppend in Flags) then
                     Destination.Append
                  else
                      DoUpdate:=false;
             end
             else
             begin
                  if (mtufEdit in Flags) then
                     Destination.Edit
                  else
                      DoUpdate:=false;
             end;

             if DoUpdate then
             begin
                  // Update record fields.
                  for i:=0 to fc do
                  begin
                       if Assigned(FOnSaveField) and (Source=self) then FOnSaveField(Self,i,Source.Fields[i]);
                       if fi[i]>=0 then
                       begin
                            if Source.Fields[fi[i]].IsNull then
                               Destination.Fields[i].Clear
                            else
                                Destination.Fields[i].AsString:=Source.Fields[fi[i]].AsString;
                       end;
                       if Assigned(FOnLoadField) and (Destination=self) then FOnLoadField(Self,i,Destination.Fields[i]);
                  end;

                  Accept:=true;
                  if Assigned(FOnLoadRecord) and (Destination=self) then FOnLoadRecord(Self,Accept);
                  if Accept then
                  begin
                       Destination.Post;
                       inc(Result);
                       if (Count>0) and (Result>=Count) then break;
                  end
                  else Destination.Cancel;
             end;

             Source.next;
        end;

     finally
        KeyFieldsList.Free;
        Progress(100,mtpcUpdate);
        FState:=mtstBrowse;
     end;
end;

procedure TkbmCustomMemTable.UpdateToDataSet(Destination:TDataSet; KeyFields:string; Flags:TkbmMemTableUpdateFlags);
var
   DestActive:boolean;
   DestDisabled:boolean;
begin
     CheckBrowseMode;

     if Destination=self then exit;

     if (assigned(FOnSave)) then FOnSave(self,mtstDataSet,nil);

     // Remember state of destination.
     DestActive:=Destination.Active;
     DestDisabled:=Destination.ControlsDisabled;

     // Dont update controls while appending to destination
     if not DestDisabled then Destination.DisableControls;
     DisableControls;
     try
        try
           // Open destination
           if not DestActive then Destination.Open;
           Destination.CheckBrowseMode;
           Destination.UpdateCursorPos;

           // Open this if not opened.
           Open;
           CheckBrowseMode;

           // Move to first record in this.
           First;
           UpdateRecords(self,Destination,KeyFields,-1,Flags);
        finally
           Destination.First;
        end;
     finally
        EnableControls;
        if not DestActive then Destination.Close;
        if not DestDisabled then Destination.EnableControls;
     end;
end;

{$IFDEF LEVEL5}
procedure TkbmCustomMemTable.UpdateToDataSet(Destination:TDataSet; KeyFields:string);
begin
     UpdateToDataSet(Destination,KeyFields,[mtufEdit,mtufAppend]);
end;
{$ENDIF}

// Fill the memorytable with data from another dataset.
procedure TkbmCustomMemTable.LoadFromDataSet(Source:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions);
var
   SourceActive:boolean;
   SourceDisabled:boolean;
   OldMasterSource:TDataSource;
   OldFiltered:boolean;
   OldEnableIndexes:boolean;
   BM:TBookmark;
   IgnoreErrors:boolean;
   widestringasutf8,
   stringaswidestring:boolean;
begin
     if Source=self then exit;

     // Check if specified append together with structure. Not allowed.
     if (mtcpoAppend in CopyOptions) and ((mtcpoStructure in CopyOptions) or (mtcpoProperties in CopyOptions)) then
        raise EMemTableError.Create(kbmCannotMixAppendStructure);

     FState:=mtstLoad;

     if (assigned(FOnLoad)) then FOnLoad(self,mtstDataSet,nil);

     // If not to append, close this table.
     if (mtcpoStructure in CopyOptions) then
        Close
     else
         if not (mtcpoAppend in CopyOptions) then EmptyTable;

     // Remember state of source.
     SourceActive:=Source.Active;
     SourceDisabled:=Source.ControlsDisabled;

     // Remember state of this.
     OldFiltered:=Filtered;
     OldMasterSource:=MasterSource;
     OldEnableIndexes:=EnableIndexes;
     if not (mtcpoDontDisableIndexes in CopyOptions) then EnableIndexes:=false;

     stringaswidestring:=(mtcpoStringAsWideString in CopyOptions);
     widestringasutf8:=(mtcpoWideStringUTF8 in CopyOptions);

     IgnoreErrors:=mtcpoIgnoreErrors in CopyOptions;
     FIgnoreReadOnly:=true;

     // Dont update controls while scrolling through source.
     if not SourceDisabled then Source.DisableControls;
     DisableControls;
     try
        if not SourceActive then Source.Open;
        try                                  // Not all datasets support this.
           BM:=Source.GetBookmark;
        except
           BM:=nil;
        end;
        try

           // Dont want to check filtering while copying.
           Filtered := False;
           MasterSource:=nil;

           // Open source.
           Source.CheckBrowseMode;
           try
              Source.UpdateCursorPos;      // Not all datasets supports this.
           except
           end;

           // Create this memorytable as a copy of the other one.
           if mtcpoStructure in CopyOptions then CreateTableAs(Source,CopyOptions);
           if not Active then Open;

           // Copy fieldproperties from source after open to also copy properties of default fields.
           if (not (mtcpoAppend in CopyOptions)) and (mtcpoProperties in CopyOptions) then
              CopyFieldsProperties(Source,self);

           CheckBrowseMode;

           // Move to first record in source.
           if not Source.BOF then Source.First;
           FLoadCount:=CopyRecords(Source,self,FLoadLimit,IgnoreErrors,widestringasutf8);
           First;
        finally
           EnableIndexes:=OldEnableIndexes;
           FCommon.MarkIndexesDirty;
           FCommon.UpdateIndexes;
           try
              Source.GotoBookmark(BM);                     // Not all datasets supports this.
           except
           end;
           try                                             // Not all datasets supports this.
              if BM<>nil then Source.FreeBookmark(BM);
           except
           end;
        end;
     finally
        FIgnoreReadOnly:=false;
        EnableControls;
        if not SourceActive then Source.Close;
        if not SourceDisabled then Source.EnableControls;
        Filtered:=OldFiltered;
        MasterSource:=OldMasterSource;
        UpdateCursorPos;
        CursorPosChanged;
        FState:=mtstBrowse;
     end;
end;

// Append the data in this memory table to another dataset.
procedure TkbmCustomMemTable.SaveToDataSet(Destination:TDataSet; CopyOptions:TkbmMemTableCopyTableOptions{$IFDEF LEVEL5} = []{$ENDIF});
var
   DestActive:boolean;
   DestDisabled:boolean;
   IgnoreErrors:boolean;
   widestringasutf8,
   stringaswidestring:boolean;
begin
     if Destination=self then exit;

     IgnoreErrors:=mtcpoIgnoreErrors in CopyOptions;
     stringaswidestring:=(mtcpoStringAsWideString in CopyOptions);
     widestringasutf8:=(mtcpoWideStringUTF8 in CopyOptions);

     FState:=mtstSave;
     if (assigned(FOnSave)) then FOnSave(self,mtstDataSet,nil);

     // Remember state of destination.
     DestActive:=Destination.Active;
     DestDisabled:=Destination.ControlsDisabled;

     // Dont update controls while appending to destination
     if not DestDisabled then Destination.DisableControls;
     DisableControls;

     try
        // Open destination
        if not DestActive then Destination.Open;
        try
           Destination.CheckBrowseMode;
           Destination.UpdateCursorPos;

           // Open this if not opened.
           Open;
           CheckBrowseMode;

           // Move to first record in this.
           First;
           FSaveCount:=CopyRecords(self,Destination,FSaveLimit,IgnoreErrors,widestringasutf8);
        finally
           Destination.First;
        end;

     finally
        EnableControls;
        if not DestActive then Destination.Close;
        if not DestDisabled then Destination.EnableControls;
        FState:=mtstBrowse;
     end;
end;

function TkbmCustomMemTable.IsSequenced: Boolean;
begin
     Result:=not Filtered;
end;

// Record rearranging.

// Move record from one place in table to another.
// Only rearranges the roworder index.
function TkbmCustomMemTable.MoveRecord(Source, Destination: Integer): Boolean;
var
   p: Pointer;
begin
     Result := False;
     if FCurIndex<>Indexes.FRowOrderIndex then exit;

     {Because property RecNo has values 1..FRecords.Count
      and FRecNo has values 0..FRecords.Count - 1}
     Dec(Source);
     Dec(Destination);

     if (Source <> Destination) and (Source > -1) and (Source < FCurIndex.FReferences.Count)
        and (Destination > -1) and (Destination < FCurIndex.FReferences.Count) then
     begin
          p:=FCurIndex.FReferences[Source];
          if Destination>Source then Dec(Destination);
          FCurIndex.FReferences.Delete(Source);
          FCurIndex.FReferences.Insert(Destination,p);
          Result:=true;
     end;
end;

// Move record to the specified destination.
function TkbmCustomMemTable.MoveCurRecord(Destination: Integer): Boolean;
begin
     Result := MoveRecord(RecNo,Destination);
end;

// Sorting.

// Callback function for TDataset to know if specified field is an index.
function TkbmCustomMemTable.GetIsIndexField(Field:TField):Boolean;
begin
     Result:=FIndexList.IndexOf(Field)>=0;
end;

// Compare two field lists.
// Returns true if they are exactly equal, otherwise false.
function TkbmCustomMemTable.IsFieldListsEqual(List1,List2:TkbmFieldList):boolean;
var
   i:integer;
begin
     Result:=false;

     if List1.Count<>List2.Count then exit;

     for i:=0 to List1.Count-1 do
         if (List1.Fields[i]<>List2.Fields[i]) {or (List1.Options[i]<>List2.Options[i])} then exit;
     Result:=true;
end;

// Compare two field lists.
// Returns true if list2 is contained in list1, otherwise false.
function TkbmCustomMemTable.IsFieldListsBegin(List1,List2:TkbmFieldList):boolean;
var
   i:integer;
begin
     Result:=false;

     if List1.Count<List2.Count then exit;

     for i:=List2.Count-1 downto 0 do
         if List1.Fields[i]<>List2.Fields[i] then exit;
     Result:=true;
end;

// Build field list from list of fieldnames.
// fld1;fld2;fld3...
// Each field can contain options:
// fldname:options
// Options can be either C for Caseinsensitive or D for descending or a combination.
procedure TkbmCustomMemTable.BuildFieldList(Dataset:TDataset; List:TkbmFieldList; const FieldNames:string);
var
   p,p1:integer;
   fld:TField;
   s,sname,sopt:string;
   opt:TkbmifoOptions;
begin
     List.Clear;
     p:=1;
     while p<=length(FieldNames) do
     begin
          // Extract fieldname and options from list of fields.
          s:=ExtractFieldName(FieldNames,p);
          p1:=pos(':',s);
          Opt:=[];
          if p1<=0 then sname:=s
          else
          begin
               sname:=copy(s,1,p1-1);
               sopt:=uppercase(copy(s,p1+1,length(s)));
               if pos('C',sopt)>0 then Include(opt,mtifoCaseInsensitive);
               if pos('D',sopt)>0 then Include(opt,mtifoDescending);
               if pos('N',sopt)>0 then Include(opt,mtifoIgnoreNull);
               if pos('P',sopt)>0 then Include(opt,mtifoPartial);
               if pos('L',sopt)>0 then Include(opt,mtifoIgnoreLocale);
          end;
          fld:=Dataset.FieldByName(sname);
          if (fld.FieldKind in [fkData,fkInternalCalc,fkCalculated,fkLookup]) and (fld.DataType in (kbmSupportedFieldTypes-kbmBinaryTypes)) then
             List.Add(fld,opt)
          else
              DatabaseErrorFmt(kbmIndexErr,[fld.DisplayName]);
          if fld.FieldKind=fkCalculated then FRecalcOnIndex:=true;
     end;

     // Update field record offsets in list.
     for p:=0 to List.Count-1 do
     begin
          fld:=TField(List.Fields[p]);
          List.FieldOfs[p]:=FCommon.GetFieldDataOffset(fld);
          List.FieldNo[p]:=fld.FieldNo;
     end;
end;

// Find field from list.
function TkbmCustomMemTable.FindFieldInList(List:TkbmFieldList; FieldName:string):TField;
var
   fld:TField;
   i:Integer;
begin
     Result:=nil;
     for i:=0 to List.Count-1 do
     begin
          fld:=List.Fields[i];
          if fld.FieldName = FieldName then
          begin
               Result:=fld;
               break;
          end;
     end;
end;

// Setup options for specific fields in the fieldlist.
procedure TkbmCustomMemTable.SetFieldListOptions(AList:TkbmFieldList; AOptions:TkbmifoOption; AFieldNames:string);
var
   i,j:integer;
   lst:TkbmFieldList;
   b:boolean;
begin
     // Set flags.
     lst:=TkbmFieldList.Create;
     try
        BuildFieldList(self,lst,AFieldNames);
        for i:=0 to AList.count-1 do
        begin
             b:=false;
             for j:=0 to lst.count-1 do
                if lst.Fields[j]=AList.Fields[i] then
                begin
                     b:=true;
                     break;
                end;

             if b then
                Include(AList.Options[i],AOptions)
             else
                Exclude(AList.Options[i],AOptions);
        end;
     finally
        lst.Free;
     end;
end;

// Sort using specified sortfields and options.
procedure TkbmCustomMemTable.SortDefault;
begin
     Sort(FSortOptions);
end;

// Do sort on specified sortfields.
procedure TkbmCustomMemTable.Sort(Options:TkbmMemTableCompareOptions);
var
   OldRange:boolean;
begin
     if not Active then exit;
     CheckBrowseMode;

     OldRange:=FRangeActive;
     FRangeActive:=false;
     try
        // Check if old sort index defined, remove it.
        if FSortIndex<>nil then
        begin
             Indexes.DeleteIndex(FSortIndex);
             FSortIndex.free;
             FSortIndex:=nil;
        end;

        // Is any sort fields setup.
        if (Trim(FSortFIeldNames)<>'') then
        begin
             // Now add a new index.
             FSortIndex:=TkbmIndex.Create(kbmDefSortIndex,self,FSortFieldNames,Options,mtitSorted,true);
             Indexes.AddIndex(FSortIndex);
             FSortIndex.Rebuild;
        end
        else
            FSortIndex:=nil;
        SwitchToIndex(FSortIndex);
     finally
        FRangeActive:=OldRange;
     end;
end;

// Do sort on specifed fieldnames.
procedure TkbmCustomMemTable.SortOn(const FieldNames:string; Options:TkbmMemTableCompareOptions);
var
   OldRange:boolean;
begin
     if not Active then exit;
     CheckBrowseMode;
     FSortedOn:=FieldNames;

     OldRange:=FRangeActive;
     FRangeActive:=false;

     // Reset curindex to make sure to set it to something afterwards.
     FCurIndex:=nil;
     try

        // Check if old sort index defined, remove it.
        if FSortIndex<>nil then
        begin
             Indexes.DeleteIndex(FSortIndex);
             FSortIndex.free;
             FSortIndex:=nil;
        end;

        // If specifying new fields to sort on, create index on those fields, otherwise select roworderindex.
        if (Trim(FieldNames)<>'') then
        begin
             // Now add a new index.
             FSortIndex:=TkbmIndex.Create(kbmDefSortIndex,self,FieldNames,Options,mtitSorted,true);
             Indexes.AddIndex(FSortIndex);
             FSortIndex.Rebuild;
        end
        else
            FSortIndex:=nil;
        SwitchToIndex(FSortIndex);
     finally
        if FCurIndex=nil then SwitchToIndex(FIndexes.FRowOrderIndex);
        FRangeActive:=OldRange;
     end;
end;

{$IFNDEF LEVEL3}
// Get specified rows as a variant.
function TkbmCustomMemTable.GetRows(Rows:Integer; Start:Variant; Fields:Variant):Variant;
var
   FldList:TkbmFieldList;
   FldCnt,RowCnt,RealCnt:integer;
   i,j:integer;
   FRows:array of array of variant;
begin
     Result:=Unassigned;

     // If Start parameter is Unassigned or kbmBookMarkCurrent
     // retrieving starts at current position.
     // If it is assigned anything other than the bookmark consts
     // a valid TBookmark is assumed (casted to LongInt when called)
     if not VarIsEmpty(Start) then
     begin
          if Start=kbmBookMarkLast then Last // doesnt make too much sense...
          else if Start=kbmBookMarkFirst then First
          else
            try
               GoToBookMark(Pointer(LongInt(Start)))
            except
            end; // raise?
     end;

     // If Rows parameter matches kbmGetRowsRest the table is scanned to the end.
     if Rows=Integer(kbmGetRowsRest) then
        RowCnt:=GetRecordCount-GetRecNo+1
     else
        RowCnt:=Rows;

     FldList:=TkbmFieldList.Create;
     try
        // Fields parameter can be
        // - single fieldname
        // - single fieldpos
        // - array of fieldnames
        // - array of fieldpos
        // - Unassigned (=all fields)
        if VarIsEmpty(Fields) then
        begin
             for i:=0 to pred(self.Fields.Count) do
               FldList.Add(self.Fields[i],[]);
        end
        else if VarIsArray(Fields) then
        begin
             if VarType(Fields[0])=varInteger then
                for i:=0 to VarArrayHighBound(Fields,1) do
                    FldList.Add(FieldByNumber(Fields[i]),[])
             else
                for i:=0 to VarArrayHighBound(Fields,1) do
                    FldList.Add(FieldByName(VarToStr(Fields[i])),[]);
        end
        else
        begin
             if VarType(Fields)=varInteger then
                FldList.Add(FieldByNumber(Fields),[])
             else
                FldList.Add(FieldByName(VarToStr(Fields)),[]);
        end;

        RealCnt:=0;
        FldCnt:=FldList.Count;
        SetLength(FRows,FldCnt,RowCnt);

        for j:=0 to pred(RowCnt) do
        begin
             for i:=0 to pred(FldCnt) do
             begin
                  // TBlobField.AsVariant doesnt return NULL for empty blobs
                  if FldList.Fields[i].IsNull then
                     FRows[i,j]:=Null
                  else
                     FRows[i,j]:=FldList.Fields[i].AsVariant;
             end;
             inc(RealCnt);
             Next;
             if EOF then Break;
        end;
     finally
        FldList.Free;
     end;

     if RealCnt<>RowCnt then
       SetLength(FRows,FldCnt,RealCnt);
     Result:=FRows;
end;
{$ENDIF}

procedure TkbmCustomMemTable.ClearModified;
begin
     FCommon.ClearModifiedFlags;
     SetIsDataModified(false);
end;

procedure TkbmCustomMemTable.Reset;
begin
     Close;
     IndexName:='';
     MasterFields:='';
     IndexFieldNames:='';
     SetDataSource(nil);
     Indexes.Clear;
{$IFNDEF LEVEL3}
     Fields.Clear;
{$ENDIF}
     FIndexDefs.Clear;
     FieldDefs.Clear;
     FIndexDefs.Update;
     FieldDefs.Update;
     Filtered:=false;
     ClearModified;
end;

// -----------------------------------------------------------------------------------
// TkbmBlobStream
// -----------------------------------------------------------------------------------

// On create, make a stream access to the specified blobfield in the current record.
constructor TkbmBlobStream.Create(Field:TBlobField;Mode:TBlobStreamMode);
var
   RecID:longint;
begin
     // Remember proposed field and mode.
     FMode:=Mode;
     FField:=Field;
     FFieldNo:=FField.FieldNo;
     FDataSet:=TkbmCustomMemTable(FField.DataSet);

     // Dont want other to mess with out blob while we are using it.
     FDataSet.FCommon.Lock;
     try
          // If a write mode, check if allowed to write.
          if Mode<>bmRead then
          begin
               if (not FDataSet.FIgnoreReadOnly) and (FField.ReadOnly) then DatabaseErrorFmt(kbmReadOnlyErr,[FField.DisplayName]);
               if not (FDataSet.State in [dsEdit, dsInsert]) then DatabaseError(kbmEditModeErr);
          end;

          // Get pointers to work buffer.
          FWorkBuffer:=PkbmRecord(FDataSet.GetActiveRecord);
          if FWorkBuffer=nil then exit;
          FpWorkBufferField:=FDataset.FCommon.GetFieldPointer(FWorkBuffer,FField);
          FpWorkBufferBlob:=PPkbmVarLength(FpWorkBufferField+1);

          // Get pointers to table record buffer.
          RecID:=FWorkBuffer^.RecordID;
          if (RecID>=0) then
          begin
               FTableRecord:=PkbmRecord(FDataSet.FCommon.FRecords.Items[RecID]);
               FpTableRecordField:=FDataSet.FCommon.GetFieldPointer(FTableRecord,FField);
               FpTableRecordBlob:=PPkbmVarLength(FpTableRecordField+1);
          end
          else
          begin
               // In case of a totally new non posted record.
               FTableRecord:=nil;
               FpTableRecordField:=nil;
               FpTableRecordBlob:=nil;
          end;

          // Write mode, truncate blob.
          if Mode=bmWrite then
               Truncate
          else
              // Read the blob data into the memorystream.
              ReadBlobData;
     finally
        FDataSet.FCommon.Unlock;
     end;
end;

// On destroy, update the blobfield in the current record if the blob has changed.
destructor TkbmBlobStream.Destroy;
begin
     try
        if FModified then
        begin
             WriteBlobData;
             FField.Modified:=true;
             FDataSet.DataEvent(deFieldChange,Longint(FField));
        end;
     except
{$IFDEF CLX}
        if Assigned(Classes.ApplicationHandleException) then
           Classes.ApplicationHandleException(Self);
{$ELSE}
        Application.HandleException(Self);
{$ENDIF}
     end;

     inherited Destroy;
end;

// Move the contents of the memorystream into the blob.
procedure TkbmBlobStream.WriteBlobData;
var
   Blob:PkbmVarLength;
   Stream:TMemoryStream;
   sz:longint;
begin
     // Check if old blob in workbuffer, free it.
     if (FpWorkBufferBlob<>nil) and (FpWorkBufferBlob^<>nil) then
     begin
          FreeVarLength(FpWorkBufferBlob^);
          FpWorkBufferBlob^:=nil;
     end;

     // If to compress the blob data, do it.
     if Assigned(FDataSet.FOnCompressBlobStream) then
     begin
          Stream:=TMemoryStream.Create;
          try
             FDataSet.FOnCompressBlobStream(FDataSet,self,Stream);
             sz:=Stream.Size;
             if sz>0 then
                Blob:=AllocVarLengthAs(Stream.Memory,sz)
             else
                Blob:=nil;
          finally
             Stream.free;
          end;
     end
     else
     begin
          sz:=self.Size;

          // Otherwise just save raw data to the inmemory blob.
          if sz>0 then
             Blob:=AllocVarLengthAs(self.Memory,self.Size)
          else
             Blob:=nil;
     end;

     // Update with new allocation.
     FpWorkBufferBlob^:=Blob;

     // Set Null flag in work record.
     if Blob<>nil then FpWorkBufferField[0]:=kbmffData
     else FpWorkBufferField[0]:=kbmffNull;
end;

// Move the contents of the blob into the memory stream.
procedure TkbmBlobStream.ReadBlobData;
var
   Blob:PkbmVarLength;
   Stream:TMemoryStream;
   sz:longint;
begin
     // Get blob.
     Blob:=FpWorkBufferBlob^;
     if Blob=nil then
     begin
          // Check if to read from table (not null).
          if (FpWorkBufferField[0]<>kbmffNull) then
             Blob:=FpTableRecordBlob^
          else
              // Nothing to read. Null blob.
              exit;
     end;

     // Get size of blob.
     sz:=GetVarLengthSize(Blob);

     // If to decompress stream, save the blob in a memory stream and decompress it.
     if Assigned(FDataSet.FOnDeCompressBlobStream) then
     begin
          Stream:=TMemoryStream.Create;
          try
             Stream.SetSize(sz);
{$IFNDEF USE_FAST_MOVE}
             Move(GetVarLengthData(Blob)^,Stream.Memory^,sz);
{$ELSE}
             FastMove(GetVarLengthData(Blob)^,Stream.Memory^,sz);
{$ENDIF}
             FDataSet.FOnDecompressBlobStream(FDataSet,Stream,self);
          finally
             Stream.free;
          end;
     end
     else
     begin
          // Copy the data to the stream.
          self.SetSize(sz);
{$IFNDEF USE_FAST_MOVE}
          Move(GetVarLengthData(Blob)^,self.Memory^,sz);
{$ELSE}
          FastMove(GetVarLengthData(Blob)^,self.Memory^,sz);
{$ENDIF}
     end;
     self.Position:=0;
end;

function TkbmBlobStream.Write(const Buffer;Count:Longint): Longint;
begin
     Result:=inherited Write(Buffer,Count);
     if (FMode=bmWrite) or (FMode=bmReadWrite) then FModified:=true;
end;

// Null a blob.
procedure TkbmBlobStream.Truncate;
begin
     Clear;

     // If blob allocated in workbuffer, remove allocation.
     if FpWorkBufferBlob^<>nil then
     begin
          FreeVarLength(FpWorkBufferBlob^);
          FpWorkBufferBlob^:=nil;
     end;

     FpWorkBufferField[0]:=kbmffNull;
     FModified:=true;
end;

{$IFNDEF LINUX}
// -----------------------------------------------------------------------------------
// TkbmThreadDataSet
// -----------------------------------------------------------------------------------

constructor TkbmThreadDataSet.Create(AOwner:TComponent);
begin
     inherited;
     FLockCount:=0;
     FSemaphore:=CreateSemaphore(nil,1,1,nil);
end;

destructor TkbmThreadDataSet.Destroy;
begin
     CloseHandle(FSemaphore);
     inherited;
end;

// Take control of the attached dataset.
// Wait for as much as TimeOut msecs to get the control.
// Setting TimeOut to INFINITE (DWORD($FFFFFFFF)) will make the lock wait for ever.
function TkbmThreadDataSet.TryLock(TimeOut:DWORD):TDataset;
var
   n:DWORD;
begin
     // Wait for critical section.
     inc(FLockCount);
     n:=WaitForSingleObject(FSemaphore,TimeOut);
     if (n=WAIT_TIMEOUT) or (n=WAIT_FAILED) then
     begin
          Result:=nil;
          dec(FLockCount);
          exit;
     end;
     Result:=FDataset;
end;

function TkbmThreadDataSet.Lock:TDataset;
begin
     Result:=TryLock(INFINITE);
end;

procedure TkbmThreadDataSet.Unlock;
begin
     dec(FLockCount);
     ReleaseSemaphore(FSemaphore,1,nil);
end;

procedure TkbmThreadDataSet.Notification(AComponent: TComponent; Operation: TOperation);
var
   WasLocked:boolean;
begin
     if (Operation=opRemove) and (AComponent=FDataSet) then
     begin
          WasLocked:=IsLocked;
          while IsLocked do Unlock;
          FDataset:=nil;
          if WasLocked then raise EMemTableError.Create(kbmDatasetRemoveLockedErr);
     end;
     inherited;
end;

procedure TkbmThreadDataSet.SetDataset(ds:TDataset);
begin
     if IsLocked then raise EMemTableError.Create(kbmSetDatasetLockErr);
     FDataSet:=ds;
end;

function TkbmThreadDataSet.GetIsLocked:boolean;
begin
     Result:=(FLockCount>0);
end;
{$ENDIF}

// -----------------------------------------------------------------------------------
// Handler for resolving delta's. Must be overridden to be usable.
// -----------------------------------------------------------------------------------

procedure TkbmCustomDeltaHandler.Notification(AComponent: TComponent; Operation: TOperation);
begin
     inherited;
     if (Operation=opRemove) and (AComponent=FDataset) then FDataset:=nil;
end;

procedure TkbmCustomDeltaHandler.CheckDataSet;
begin
     if FDataSet=nil then raise EMemTableError.Create(kbmDeltaHandlerAssign);
end;

procedure TkbmCustomDeltaHandler.Resolve;
var
   i:integer;
   pRec,pOrigRec:PkbmRecord;
   st:TUpdateStatus;
   oAttachedAutoRefresh:boolean;
   Retry:boolean;
begin
     CheckDataSet;
     oAttachedAutoRefresh:=FDataSet.FAttachedAutoRefresh;
     FDataSet.FAttachedAutoRefresh:=false;
     FDataSet.FCommon.Lock;
     try
        // Do not refresh views _while_ resolving. Wait until afterwards.

        for i:=0 to FDataSet.FCommon.FRecords.Count-1 do
        begin
             // Check status of record.
             pRec:=PkbmRecord(FDataSet.FCommon.FRecords.Items[i]);
             if pRec=nil then continue;

             // Find oldest version.
             pOrigRec:=pRec;
             while pOrigRec^.PrevRecordVersion<>nil do
                   pOrigRec:=pOrigRec^.PrevRecordVersion;

             // Check what status to react on.
             if pRec^.UpdateStatus=usDeleted then
             begin
                  // Dont resolve inserts that were deleted again.
                  if pOrigRec^.UpdateStatus=usInserted then st:=usUnmodified
                  else st:=usDeleted;
             end
             else if pOrigRec^.UpdateStatus=usInserted then st:=usInserted
             else st:=pRec^.UpdateStatus;

             FPRecord:=pRec;
             FPOrigRecord:=pOrigRec;

             repeat
               Retry:=false;
               case st of
                    usDeleted:    DeleteRecord(Retry,st);
                    usInserted:   InsertRecord(Retry,st);
                    usModified:   ModifyRecord(Retry,st);
                    usUnModified: UnmodifiedRecord(Retry,st);
               end;
             until not Retry;
        end;
     finally
        FDataSet.FCommon.Unlock;

        // Check if to refresh other tables.
        FDataSet.FAttachedAutoRefresh:=oAttachedAutoRefresh;
        if FDataset.FAttachedAutoRefresh then
           FDataSet.FCommon.RefreshTables(nil);
     end;
end;

procedure TkbmCustomDeltaHandler.InsertRecord(var Retry:boolean; var State:TUpdateStatus);
begin
end;

procedure TkbmCustomDeltaHandler.DeleteRecord(var Retry:boolean; var State:TUpdateStatus);
begin
end;

procedure TkbmCustomDeltaHandler.ModifyRecord(var Retry:boolean; var State:TUpdateStatus);
begin
end;

procedure TkbmCustomDeltaHandler.UnmodifiedRecord(var Retry:boolean; var State:TUpdateStatus);
begin
end;

function TkbmCustomDeltaHandler.GetFieldCount:integer;
begin
     CheckDataSet;
     Result:=FDataSet.FieldCount;
end;

function TkbmCustomDeltaHandler.GetOrigValues(Index:integer):Variant;
begin
     CheckDataSet;
     FDataSet.FOverrideActiveRecordBuffer:=FPOrigRecord;
     try
        if FDataSet.Fields[Index].IsNull then
           Result:=Null
        else
            Result:=FDataSet.Fields[Index].AsVariant;
     finally
        FDataSet.FOverrideActiveRecordBuffer:=nil;
     end;
end;

function TkbmCustomDeltaHandler.GetValues(Index:integer):Variant;
begin
     CheckDataSet;
     FDataSet.FOverrideActiveRecordBuffer:=FPRecord;
     try
        if FDataSet.Fields[Index].IsNull then
           Result:=Null
        else
            Result:=FDataSet.Fields[Index].AsVariant;

        if Assigned(FOnGetValue) then FOnGetValue(self,FDataSet.Fields[Index],Result);
     finally
        FDataSet.FOverrideActiveRecordBuffer:=nil;
     end;
end;

function TkbmCustomDeltaHandler.GetOrigValuesByName(Name:string):Variant;
var
   fld:TField;
begin
     CheckDataSet;
     FDataSet.FOverrideActiveRecordBuffer:=FPOrigRecord;
     try
        fld:=FDataSet.FieldByName(Name);
        if fld.IsNull then
           Result:=Null
        else
            Result:=fld.AsVariant;
     finally
        FDataSet.FOverrideActiveRecordBuffer:=nil;
     end;
end;

function TkbmCustomDeltaHandler.GetValuesByName(Name:string):Variant;
var
   fld:TField;
begin
     CheckDataSet;
     FDataSet.FOverrideActiveRecordBuffer:=FPRecord;
     try
        fld:=FDataSet.FieldByName(Name);
        if fld.IsNull then
           Result:=Null
        else
            Result:=fld.AsVariant;
        if Assigned(FOnGetValue) then FOnGetValue(self,fld,Result);
     finally
        FDataSet.FOverrideActiveRecordBuffer:=nil;
     end;
end;

function TkbmCustomDeltaHandler.GetFieldNames(Index:integer):string;
begin
     CheckDataSet;
     Result:=FDataSet.Fields[Index].FieldName;
end;

function TkbmCustomDeltaHandler.GetFields(Index:integer):TField;
begin
     CheckDataSet;
     Result:=FDataSet.Fields[Index];
end;

function TkbmCustomDeltaHandler.GetRecordNo:longint;
begin
     Result:=FPRecord^.RecordNo+1;
end;

function TkbmCustomDeltaHandler.GetUniqueRecordID:longint;
begin
     Result:=FPRecord^.UniqueRecordID;
end;

// TkbmCustomStreamFormat
//*******************************************************************

constructor TkbmCustomStreamFormat.Create(AOwner:TComponent);
begin
     inherited;
     sfData:=[sfSaveData,sfLoadData];
     sfCalculated:=[];
     sfLookup:=[];
     sfNonVisible:=[sfSaveNonVisible,sfLoadNonVisible];
     sfBlobs:=[sfSaveBlobs,sfLoadBlobs];
     sfDef:=[sfSaveDef,sfLoadDef];
     sfIndexDef:=[sfSaveIndexDef,sfLoadIndexDef];
     sfFiltered:=[sfSaveFiltered];
     sfIgnoreRange:=[sfSaveIgnoreRange];
     sfIgnoreMasterDetail:=[sfSaveIgnoreMasterDetail];
     sfDeltas:=[];
     sfDontFilterDeltas:=[];
     sfAppend:=[];
     sfFieldKind:=[sfSaveFieldKind];
     sfFromStart:=[sfLoadFromStart];
//     FAutoReposition:=true;
end;

procedure TkbmCustomStreamFormat.Assign(Source:TPersistent);
begin
     if Source is TkbmCustomStreamFormat then
     begin
          sfData:=TkbmCustomStreamFormat(Source).sfData;
          sfCalculated:=TkbmCustomStreamFormat(Source).sfCalculated;
          sfLookup:=TkbmCustomStreamFormat(Source).sfLookup;
          sfNonVisible:=TkbmCustomStreamFormat(Source).sfNonVisible;
          sfBlobs:=TkbmCustomStreamFormat(Source).sfBlobs;
          sfDef:=TkbmCustomStreamFormat(Source).sfDef;
          sfIndexDef:=TkbmCustomStreamFormat(Source).sfIndexDef;
          sfFiltered:=TkbmCustomStreamFormat(Source).sfFiltered;
          sfIgnoreRange:=TkbmCustomStreamFormat(Source).sfIgnoreRange;
          sfIgnoreMasterDetail:=TkbmCustomStreamFormat(Source).sfIgnoreMasterDetail;
          sfDeltas:=TkbmCustomStreamFormat(Source).sfDeltas;
          sfDontFilterDeltas:=TkbmCustomStreamFormat(Source).sfDontFilterDeltas;
          sfAppend:=TkbmCustomStreamFormat(Source).sfAppend;
          sfFieldKind:=TkbmCustomStreamFormat(Source).sfFieldKind;
          sfFromStart:=TkbmCustomStreamFormat(Source).sfFromStart;
          exit;
     end;
     inherited Assign(Source);
end;

procedure TkbmCustomStreamFormat.SetIgnoreAutoIncPopulation(ADataset:TkbmCustomMemTable; Value:boolean);
begin
     ADataset.FIgnoreAutoIncPopulation:=value;
end;

procedure TkbmCustomStreamFormat.SetVersion(AVersion:string);
begin
end;

function  TkbmCustomStreamFormat.GetVersion:string;
begin
     Result:='1.00';
end;

procedure TkbmCustomStreamFormat.DetermineSaveFields(ADataset:TkbmCustomMemTable);
var
   i:integer;
   nf:integer;
begin
     // Setup flags for fields to save.
     with ADataset do
     begin
          nf:=Fieldcount;
{$IFDEF LEVEL4}
          SetLength(SaveFields,nf);
{$ELSE}
          SaveFieldsCount:=nf;
{$ENDIF}

          for i:=0 to nf-1 do
          begin
               // Default dont save this field.
               SaveFields[i]:=-1;

               // If a blob field, only save if specified.
               if (Fields[i].DataType in kbmBlobTypes) then
               begin
                    if not (sfSaveBlobs in sfBlobs) then continue;
                    SaveFields[i]:=i;
               end;

               // Only save fields of specific types.
               case Fields[i].FieldKind of
                    fkData,fkInternalCalc: if sfSaveData in sfData then SaveFields[i]:=i;
                    fkCalculated: if sfSaveCalculated in sfCalculated then SaveFields[i]:=i;
                    fkLookup: if sfSaveLookup in sfLookup then SaveFields[i]:=i;
                    else SaveFields[i]:=-1;
               end;

               // If not to save invisible fields, dont.
               if not (Fields[i].Visible or (sfSaveNonVisible in sfNonVisible)) then SaveFields[i]:=-1;
          end;
     end;
end;

procedure TkbmCustomStreamFormat.DetermineLoadFields(ADataset:TkbmCustomMemTable; Situation:TkbmDetermineLoadFieldsSituation);
var
   i,j,nf:integer;
   lst:TStringList;
begin
     // Setup flags for fields to save.
     lst:=TStringList.Create;
     try
        with ADataset do
        begin
             lst.Clear;
             DetermineLoadFieldIDs(ADataset,lst,Situation);
             nf:=lst.Count;
{$IFDEF LEVEL4}
             SetLength(LoadFields,nf);
{$ELSE}
             LoadFieldsCount:=nf;
{$ENDIF}

             for i:=0 to nf-1 do
             begin
                  // Default dont load this field.
                  LoadFields[i]:=-1;

                  // Let child component make initial desision of what to load and order.
                  DetermineLoadFieldIndex(ADataset,lst.Strings[i],nf,i,LoadFields[i],Situation);

                  // Only load fields of specific types.
                  j:=LoadFields[i];
                  if j>=0 then
                  begin
                       case Fields[j].FieldKind of
                            fkData,fkInternalCalc: if not (sfLoadData in sfData) then LoadFields[i]:=-1;
                            fkCalculated: if not (sfLoadCalculated in sfCalculated) then LoadFields[i]:=-1;
                            fkLookup: if not (sfLoadLookup in sfLookup) then LoadFields[i]:=-1;
                            else LoadFields[i]:=-1;
                       end;

                       // If a blob field, only load if specified.
                       if (Fields[j].DataType in kbmBlobTypes) and (not (sfLoadBlobs in sfBlobs)) then LoadFields[i]:=-1;

                       // If not to load invisible fields, dont.
                       if not (Fields[j].Visible or (sfLoadNonVisible in sfNonVisible)) then LoadFields[i]:=-1;
                  end;
             end;
        end;
     finally
        lst.Free;
     end;
end;

procedure TkbmCustomStreamFormat.BeforeSave(ADataset:TkbmCustomMemTable);
begin
     with ADataset do
     begin
          DisableControls;

          Common.Lock;
          TableState:=mtstSave;
          Progress(0,mtpcSave);

          FWasFiltered:=Filtered;
          FWasRangeActive:=FRangeActive;
          FWasMasterLinkUsed:=FMasterLinkUsed;

          if Filtered and (sfSaveFiltered in sfFiltered) then Filtered:=false;
          if FMasterLinkUsed and (sfSaveIgnoreMasterDetail in sfIgnoreMasterDetail) then FMasterLinkUsed:=false;
          if RangeActive and (sfSaveIgnoreRange in sfIgnoreRange) then FRangeActive:=false;

          // If to compress stream, create memory stream to save to instead.
          if Assigned(FOnCompress) then
             FWorkStream:=TMemoryStream.Create
          else
             FWorkStream:=FOrigStream;

          // Check if to append. If not truncate stream.
          if (sfSaveAppend in sfAppend) then
             FWorkStream.Seek(0,soFromEnd)
          else if not (sfSaveInsert in sfAppend) then
          begin
               FWorkStream.Size:=0;
               FWorkStream.Position:=0;
          end;

          // Determine fields to save.
          DetermineSaveFields(ADataset);

          SetIsFiltered;
     end;
end;

procedure TkbmCustomStreamFormat.AfterSave(ADataset:TkbmCustomMemTable);
begin
     try
        // If to compress stream do the compression to the dest stream.
        if Assigned(FOnCompress) then
           FOnCompress(ADataset,FWorkStream,FOrigStream);

        with ADataset do
        begin
             FMasterLinkUsed:=true;
             FRangeActive:=FWasRangeActive;
             Filtered:=FWasFiltered;

             TableState:=mtstBrowse;
             Progress(100,mtpcSave);
             Common.Unlock;

             SetIsFiltered;
             EnableControls;
        end;
     finally
        if FWorkStream<>FOrigStream then
        begin
             FWorkStream.Free;
             FWorkStream:=nil;
        end;
     end;
end;

procedure TkbmCustomStreamFormat.SaveDef(ADataset:TkbmCustomMemTable);
begin
end;

procedure TkbmCustomStreamFormat.SaveData(ADataset:TkbmCustomMemTable);
begin
end;

procedure TkbmCustomStreamFormat.Save(ADataset:TkbmCustomMemTable);
begin
     if Assigned(FOnBeforeSave) then FOnBeforeSave(self);
     SaveDef(ADataset);
     SaveData(ADataset);
     if Assigned(FOnAfterSave) then FOnAfterSave(self);
end;

procedure TkbmCustomStreamFormat.BeforeLoad(ADataset:TkbmCustomMemTable);
begin
     with ADataset do
     begin
          // Dont let persistence react on internal open/close statements.
          DisableControls;

          Common.Lock;

          TableState:=mtstLoad;

          FWasPersistent:=FPersistent;
          FWasEnableIndexes:=FEnableIndexes;

          FPersistent:=false;
          FEnableIndexes:=false;

          FIgnoreReadOnly:=true;
          FIgnoreAutoIncPopulation:=true;

          if Active and (RecordCount>0) and FAutoReposition then
             FBookmark:=GetBookmark
          else
             FBookmark:=nil;
          Progress(0,mtpcLoad);

          // If to decompress stream, create memory stream to load from instead.
          if Assigned(OnDecompress) then
          begin
               FWorkStream:=TMemoryStream.Create;
               if sfLoadFromStart in sfFromStart then
                  FOrigStream.Position:=0;
               OnDecompress(ADataset,FOrigStream,FWorkStream);
               FWorkStream.Position:=0;
          end
          else
          begin
               FWorkStream:=FOrigStream;
               if sfLoadFromStart in sfFromStart then
                  FWorkStream.Position:=0;
          end;

          // Determine fields to load.
          DetermineLoadFields(ADataset,dlfBeforeLoad);
     end;
end;

procedure TkbmCustomStreamFormat.AfterLoad(ADataset:TkbmCustomMemTable);
begin
     try
        with ADataset do
        begin
             // Dont let persistence react on internal open/close statements.
             FPersistent:=FWasPersistent;
             FEnableIndexes:=FWasEnableIndexes;

             FIgnoreReadOnly:=false;
             FIgnoreAutoIncPopulation:=false;

             Common.MarkIndexesDirty;
             Common.RebuildIndexes;
             Common.Unlock;

             ClearBuffers;

             if FAutoReposition then
             begin

                  if Assigned(FBookmark) then
                  begin
                       if BookmarkValid(FBookmark) then
                          GotoBookmark(FBookmark)
                       else
                           First;
                       FreeBookmark(FBookmark);
                       FBookmark:=nil;
                  end
                  else
                      First;
             end
             else
                 First;

             EnableControls;
             
             Progress(100,mtpcLoad);
             TableState:=mtstBrowse;
//             if FAutoReposition then Refresh;
             if FAutoUpdateFieldVariables then UpdateFieldVariables;
             Refresh;
        end;
     finally
        if FWorkStream<>FOrigStream then
        begin
             FWorkStream.Free;
             FWorkStream:=nil;
        end;
     end;
end;

procedure TkbmCustomStreamFormat.LoadDef(ADataset:TkbmCustomMemTable);
begin
end;

procedure TkbmCustomStreamFormat.LoadData(ADataset:TkbmCustomMemTable);
begin
end;

procedure TkbmCustomStreamFormat.Load(ADataset:TkbmCustomMemTable);
begin
     if Assigned(FOnBeforeLoad) then FOnBeforeLoad(self);
     LoadDef(ADataset);
     DetermineLoadFields(ADataset,dlfAfterLoadDef); // Give another chance. LoadDef might have changed something,
{$IFDEF LEVEL4}
     if Length(LoadFields)<=0 then
{$ELSE}
     if LoadFieldsCount<=0 then
{$ENDIF}
        raise EMemTableError.Create('Couldnt determine field count for load.');
     LoadData(ADataset);
     if Assigned(FOnAfterLoad) then FOnAfterLoad(self);
end;

procedure TkbmCustomStreamFormat.DetermineLoadFieldIDs(ADataset:TkbmCustomMemTable; AList:TStringList; Situation:TkbmDetermineLoadFieldsSituation);
var
   i:integer;
begin
     AList.Clear;
     for i:=0 to ADataset.FieldCount-1 do
         AList.Add(ADataset.Fields[i].DisplayName);
end;

procedure TkbmCustomStreamFormat.DetermineLoadFieldIndex(ADataset:TkbmCustomMemTable; ID:string; FieldCount:integer; OrigIndex:integer; var NewIndex:integer; Situation:TkbmDetermineLoadFieldsSituation);
begin
     // Default dont load anything.
end;

// -----------------------------------------------------------------------------------
// Registration for Delphi 3 / C++ Builder 3
// -----------------------------------------------------------------------------------

{$IFDEF LEVEL3}
procedure Register;
begin
     RegisterComponents('kbmMemTable', [TkbmMemTable,TkbmThreadDataSet]);
end;
{$ENDIF}

end.




