{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit implements various hash tables to look up an object in a
/// list quickly.
/// </summary>
Unit i18nHashList;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, Types, Generics.Defaults;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// EKeyNotFoundError is the exception class of the hash table errors.
  /// </summary>
  /// <remarks>
  /// EKeyNotFoundError occurs when the application refers to a hash key that does
  /// not exist.
  /// </remarks>
  /// <seealso cref="THashList"/>
  {$Endregion}
   EKeyNotFoundError = Class(Exception);

 {$Region 'xmldoc'}
 /// <summary>
 /// TKeyLookup represents a hash table that associates a value to a unique key.
 /// </summary>
 /// <remarks>
 /// Use TKeyLookup when you need to locate a value using a key. Both keys and values
 /// are type generic.
 /// </remarks>
 {$Endregion}

   TKeyLookup<TKey, TValue> = Class(TObject)
    {$IFDEF COMPILER2010_UP}
    Private
     Type
     PPEntry = ^PEntry;
     PEntry  = ^TEntry;
     TEntry  = Record
      Next  : PEntry;
      Key   : TKey;
      Value : TValue;
     End;
    Private
     HashMask : Cardinal;
     Buckets  : Array Of PEntry;
     IKey     : IEqualityComparer<TKey>;
     Function AllocateEntry(Const Key : TKey; Const Value : TValue) : PEntry; Inline;
     Function ReleaseEntry(Entry : PEntry) : PEntry; Inline;
     Function LookupBucket(Const Key : TKey) : PPEntry;
     Function LookupEntry(Const Key : TKey) : PEntry; Inline;
     {$ELSE}
    Private
     // Delphi 2009 goes nuts if we use a pointer to a generic type. In this
     // case an internal error occurs in another unit that referencing the unit
     // of the pointer decleration.
     // Because an object is actually a pointer, we can work with generic objects
     // as they are pointers. But we will lose some performance because object
     // allocation/deallocation is slower than GetMem/Freemem approach.
     // Anyway, TKeyLookup class is still much faster than TDictionary class that
     // is declared in the Generics.Collections unit.
     Type
     TEntry = Class
      Next  : TEntry;
      Key   : TKey;
      Value : TValue;
     End;
    Private
     HashMask : Cardinal;
     Buckets  : Array Of TEntry;
     IKey     : IEqualityComparer<TKey>;
     Function AllocateEntry(Const Key : TKey; Const Value : TValue) : TEntry; Inline;
     Function ReleaseEntry(Entry : TEntry) : TEntry; Inline;
     Function LookupBucket(Const Key : TKey) : Pointer;
     Function LookupEntry(Const Key : TKey) : TEntry; Inline;
     {$ENDIF}
    Public
     Type
     {$Region 'xmldoc'}
     /// <summary>
     /// TCallback is the type for callback handlers that respond when traversing
     /// entries of a lookup hash table.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the current entry.
     /// </param>
     /// <param name="Value">
     /// The value of the current entry.
     /// </param>
     /// <param name="UserData">
     /// A user-defined value supplied as the UserData parameter of the
     /// <see cref="ForEach"/> method.
     /// </param>
     /// <returns>
     /// Returns <see langword="false"/> if there is no need to continue traversing,
     /// otherwise returns <see langword="true"/>.
     /// </returns>
     /// <seealso cref="ForEach"/>
     {$Endregion}
     TCallback = Reference To Function(Const Key : TKey; Const Value : TValue) : Boolean;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the lookup hash table.
     /// </summary>
     /// <param name="EqualityComparer">
     /// The interface that provides equality comparer and hasher functions for
     /// the keys.
     /// </param>
     /// <param name="Size">
     /// The bucket size of the hash table. This value should be a power of two,
     /// otherwise the constructor rounds it up to the next power of two.
     /// </param>
     {$Endregion}
     Constructor Create(EqualityComparer : IEqualityComparer<TKey>; Size : Cardinal = 128); Overload;
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the lookup hash table.
     /// </summary>
     /// <param name="EqualityComparer">
     /// The interface that provides equality comparer and hasher functions for the
     /// keys.
     /// </param>
     /// <param name="Size">
     /// The bucket size of the hash table. This value should be a power of two,
     /// otherwise the constructor rounds it up to the next power of two.
     /// </param>
     {$Endregion}
     Constructor Create(Size : Cardinal = 128); Overload;
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys the hash table and releases its allocated memory.
     /// </summary>
     {$Endregion}
     Destructor Destroy; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Removes all entries from the hash table.
     /// </summary>
     {$Endregion}
     Procedure Clear;
     {$Region 'xmldoc'}
     /// <summary>
     /// Copies entries from another hash table.
     /// </summary>
     /// <param name="Source">
     /// The source hash table.
     /// </param>
     {$Endregion}
     Procedure CopyFrom(Source : TKeyLookup<TKey, TValue>);
     {$Region 'xmldoc'}
     /// <summary>
     /// Adds a key-value pair to the hash table.
     /// </summary>
     /// <param name="Key">
     /// The key to add.
     /// </param>
     /// <param name="Value">
     /// The value associated with the key.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key was not already in the hash
     /// table. Otherwise, returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="AddOrUpdate"/>
     /// <seealso cref="Update"/>
     {$Endregion}
     Function Add(Const Key : TKey; Const Value : TValue) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Changes the value that is associated with a key.
     /// </summary>
     /// <param name="Key">
     /// The key to modify its associated value.
     /// </param>
     /// <param name="Value">
     /// The new value.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="Add"/>
     /// <seealso cref="AddOrUpdate"/>
     {$Endregion}
     Function Update(Const Key : TKey; Const Value : TValue) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// If a specified key does not exist in the hash table, adds the key-value
     /// pair to the hash table. Otherwise, updates the value associated with the
     /// key.
     /// </summary>
     /// <param name="Key">
     /// The key to add or update.
     /// </param>
     /// <param name="Value">
     /// The value associated with the key.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if an existing entry updated. Returns
     /// <see langword="false"/> if a new entry added.
     /// </returns>
     /// <seealso cref="Add"/>
     /// <seealso cref="Update"/>
     {$Endregion}
     Function AddOrUpdate(Const Key : TKey; Const Value : TValue) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Removes a key and its associated value from the hash table.
     /// </summary>
     /// <param name="Key">
     /// The key to delete.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function Remove(Const Key : TKey) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Returns the value that is associated with a key.
     /// </summary>
     /// <param name="Key">
     /// The key whose value to retrieve.
     /// </param>
     /// <param name="Value">
     /// The value associated with the key if the key is found.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function Retrieve(Const Key : TKey; Out Value : TValue) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Indicates whether a key is in the hash table.
     /// </summary>
     /// <param name="Key">
     /// The key to check.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function Exists(Const Key : TKey) : Boolean; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Executes a callback for every key-value pair in the hash table.
     /// </summary>
     /// <param name="Callback">
     /// The callback to execute for each key-value pair.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if it executes the callback for every key-value
     /// pair in the hash table. Returns <see langword="false"/> if the callback returns
     /// <see langword="false"/> for some key-value pair, causing any subsequent key-value
     /// pairs to be skipped.
     /// </returns>
     {$Endregion}
     Function ForEach(Callback : TCallback) : Boolean;
   End;

   THashList = Class;

 {$Region 'xmldoc'}
 /// <summary>
 /// THashItem is an individual item of a <see cref="THashList"/> class.
 /// </summary>
 /// <remarks>
 /// Use THashItem as a base class to define an object that can be maintained
 /// by an instance of <see cref="THashList"/> class.
 /// </remarks>
 /// <seealso cref="THashList"/>
 {$Endregion}

     THashItem = Class Abstract(TPersistent)
    Private
     HashList  : THashList;
     HashNext  : THashItem;
     OrderPrev : THashItem;
     OrderNext : THashItem;
     Function GetIndex : Integer;
    Protected
     {$Region 'xmldoc'}
     /// <summary>
     /// Returns the owner of the object.
     /// </summary>
     /// <returns>
     /// The owner of the object.
     /// </returns>
     {$Endregion}
     Function GetOwner : TPersistent; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Returns the unique key that was passed as parameter to the constructor
     /// of the object.
     /// </summary>
     /// <returns>
     /// Returns the unique key of the object.
     /// </returns>
     /// <seealso cref="Create"/>
     {$Endregion}
     Function GetKey : String; Virtual; Abstract;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class.
     /// </summary>
     /// <param name="AKey">
     /// The unique key of the instance that will be used to look up the object
     /// in a <see cref="THashList"/> object.
     /// </param>
     {$Endregion}
     Constructor Create(Const AKey : String); Virtual; Abstract;
     {$Region 'xmldoc'}
     /// <summary>
     /// Deletes the object from the owner list and destroys its instance.
     /// </summary>
     {$Endregion}
     Procedure Delete;
     {$Region 'xmldoc'}
     /// <summary>
     /// Places this object on top of the owner list.
     /// </summary>
     /// <returns>
     /// Returns <see langword="true"/> if the object is maintained by a <see cref="THashList"/>
     /// object, otherwise returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveBefore"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveToFirst : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Places this object on bottom of the owner list.
     /// </summary>
     /// <returns>
     /// Returns <see langword="true"/> if the object is maintained by a <see cref="THashList"/>
     /// object, otherwise returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveBefore"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveToLast : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Places this object before another object in the owner list.
     /// </summary>
     /// <param name="Item">
     /// The object before which this object will be placed.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if both objects are maintained by the same
     /// <see cref="THashList"/> object, otherwise returns <see langword="false"/>.</returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveBefore(Item : THashItem) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Places this object after another object in the owner list.
     /// </summary>
     /// <param name="Item">
     /// The object after which this object will be placed.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if both objects are maintained by the same
     /// <see cref="THashList"/> object, otherwise returns <see langword="false"/>.</returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveBefore"/>
     {$Endregion}
     Function MoveAfter(Item : THashItem) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="THashList"/> object that owns and maintains this object.
     /// </summary>
     {$Endregion}
     Property Owner : THashList Read HashList;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the object in the owner list that is placed just before this
     /// object.
     /// </summary>
     /// <seealso cref="Next"/>
     {$Endregion}
     Property Prev : THashItem Read OrderPrev;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the object in the owner list that is placed just after this
     /// object.
     /// </summary>
     /// <seealso cref="Prev"/>
     {$Endregion}
     Property Next : THashItem Read OrderNext;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the position of this object in the owner list.
     /// </summary>
     {$Endregion}
     Property Index : Integer Read GetIndex;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// This is a class reference for <see cref="THashItem"/> class or for one of
 /// its descendants.
 /// </summary>
 /// <remarks>
 /// THashItemClass is the metaclass for <see cref="THashItem"/>. Its value is the
 /// class reference for <see cref="THashItem"/> or for one of its descendants.
 /// </remarks>
 {$Endregion}

   THashItemClass = Class Of THashItem;

 {$Region 'xmldoc'}
 /// <summary>
 /// THashList maintains a list of <see cref="THashItem"/> objects.
 /// </summary>
 /// <remarks>
 /// <para>
 /// THashList is combination of a double-linked list and a hash map. Therefore,
 /// it not only provides a fast sequential access to the maintained items but
 /// also can locate an individual item very quickly.
 /// </para>
 /// <para>
 /// Use THashList to store and maintain a list of <see cref="THashItem"/>
 /// objects. THashList provides properties and methods to add, delete, rearrange,
 /// locate, access, and sort the <see cref="THashItem"/> objects.
 /// </para>
 /// </remarks>
 /// <seealso cref="THashItem"/>
 {$Endregion}

     THashList = Class Abstract(TPersistent)
    Private
     Buckets     : Array Of THashItem;
     HashMask    : Cardinal;
     fCount      : Integer;
     fOrderFirst : THashItem;
     fOrderLast  : THashItem;
     Function GetItems(Const Key : String) : THashItem;
     Procedure TakeItemOut(Item : THashItem);
    Protected
     {$Region 'xmldoc'}
     /// <summary>
     /// Returns the <see cref="THashItem"/> class that represents individual
     /// items of the list.
     /// </summary>
     /// <returns>
     /// The <see cref="THashItem"/> class or one of its descendants.
     /// </returns>
     {$Endregion}
     Function GetItemClass : THashItemClass; Virtual; Abstract;
     {$Region 'xmldoc'}
     /// <summary>
     /// Responds when items are added to or removed from the list.
     /// </summary>
     /// <param name="Item">
     /// The item that was just added to or that is about to be removed from the
     /// list.
     /// </param>
     /// <param name="Action">
     /// Indicates whether item was added, is about to be removed, or is about to
     /// be deleted.
     /// </param>
     {$Endregion}
     Procedure Notify(Item : THashItem; Action : TListNotification); Virtual;
     {$Region 'xmldoc'}
     /// <summary>
     /// Finds an item in the list that is associated with a specified key.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to look up.
     /// </param>
     /// <param name="Item">
     /// The item that is found.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function FindKey(Const Key : String; Out Item : THashItem) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Searches for a specified key in the list and if no item is associated
     /// to the key, creates the item.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to look up or create.
     /// </param>
     /// <param name="Item">
     /// The item that is found or newly created.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is not found and a new item
     /// is created for it, otherwise returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="ExtractKey"/>
     {$Endregion}
     Function AddKey(Const Key : String; Out Item : THashItem) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Removes an item with a specified key from the list without destroying
     /// the item itself.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to look up and remove.
     /// </param>
     /// <param name="Item">
     /// The item that is found and removed from the list.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="ExtractKey"/>
     {$Endregion}
     Function ExtractKey(Const Key : String; Out Item : THashItem) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Relocates an item to place before another item.
     /// </summary>
     /// <param name="Item">
     /// The item to move.
     /// </param>
     /// <param name="ItemAfter">
     /// The item that will be placed after the target item.
     /// </param>
     /// <seealso cref="MoveItemAfter"/>
     {$Endregion}
     Procedure MoveItemBefore(Item, ItemAfter : THashItem);
     {$Region 'xmldoc'}
     /// <summary>
     /// Relocates an item to place after another item.
     /// </summary>
     /// <param name="Item">
     /// The item to move.
     /// </param>
     /// <param name="ItemBefore">
     /// The item that will be placed before the target item.
     /// </param>
     /// <seealso cref="MoveItemBefore"/>
     {$Endregion}
     Procedure MoveItemAfter(Item, ItemBefore : THashItem);
     {$Region 'xmldoc'}
     /// <summary>
     /// Calculates a 32-bit hash value of a specified key.
     /// </summary>
     /// <param name="Key">
     /// The key to calculate its hash value.
     /// </param>
     /// <returns>
     /// The 32-bit hash value of the key.
     /// </returns>
     {$Endregion}
     Function HashOf(Const Key : String) : Cardinal; Virtual;
     {$Region 'xmldoc'}
     /// <summary>
     /// Compares two key strings in a case insensitive manner.
     /// </summary>
     /// <param name="Key1">
     /// The first key.
     /// </param>
     /// <param name="Key2">
     /// The second key.
     /// </param>
     /// <returns>
     /// Returns zero if both keys are identical. Returns -1 if <paramref name="Key1"/>
     /// is smaller than <paramref name="Key2"/>. Returns 1 if <paramref name="Key1"/>
     /// is bigger than <paramref name="Key2"/>.
     /// </returns>
     {$Endregion}
     Function Compare(Const Key1, Key2 : String) : Integer; Virtual;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class.
     /// </summary>
     /// <param name="Size">
     /// The bucket size of the hash table. This value should be a power of two,
     /// otherwise the constructor rounds it up to the next power of two.
     /// </param>
     {$Endregion}
     Constructor Create(Size : Cardinal = 256); Virtual;
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys the list and all of its items.
     /// </summary>
     {$Endregion}
     Destructor Destroy; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys all the items in the list.
     /// </summary>
     {$Endregion}
     Procedure Clear; Virtual;
     {$Region 'xmldoc'}
     /// <summary>
     /// Copies items of another list to this list.
     /// </summary>
     /// <param name="Source">
     /// The source list.
     /// </param>
     {$Endregion}
     Procedure Assign(Source : TPersistent); Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Moves the item with a specified key to top of the list.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to move.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveBefore"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveToFirst(Const Key : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Moves the item with a specified key to bottom of the list.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to move.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveBefore"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveToLast(Const Key : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Moves the item with a specified key before another item represented by
     /// its key.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to move.
     /// </param>
     /// <param name="KeyAfter">
     /// The unique key of the item that will be placed after the target item.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if both keys are found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveAfter"/>
     {$Endregion}
     Function MoveBefore(Const Key, KeyAfter : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Moves the item with a specified key after another item represented by
     /// its key.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to move.
     /// </param>
     /// <param name="KeyBefore">
     /// The unique key of the item that will be placed before the target item.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if both keys are found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="MoveToFirst"/>
     /// <seealso cref="MoveToLast"/>
     /// <seealso cref="MoveBefore"/>
     {$Endregion}
     Function MoveAfter(Const Key, KeyBefore : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Indicates whether an item with a specified key is in the list.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to examine.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="Find"/>
     {$Endregion}
     Function Exists(Const Key : String) : Boolean; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Finds an item with a specified key in the list.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to find.
     /// </param>
     /// <returns>
     /// The found item or <see langword="nil"/> if the key is not found.
     /// </returns>
     /// <seealso cref="Exists"/>
     {$Endregion}
     Function Find(Const Key : String) : THashItem;
     {$Region 'xmldoc'}
     /// <summary>
     /// Adds a new item if a specified key is not already in the list.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the new item.
     /// </param>
     /// <returns>
     /// The item with the specified key.
     /// </returns>
     {$Endregion}
     Function Add(Const Key : String) : THashItem;
     {$Region 'xmldoc'}
     /// <summary>
     /// Removes an item with a specified key from the list and destroys its
     /// object.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to delete.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the key is found, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     /// <seealso cref="Extract"/>
     {$Endregion}
     Function Delete(Const Key : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Removes an item with a specified key from the list without destroying
     /// its object.
     /// </summary>
     /// <param name="Key">
     /// The unique key of the item to extract.
     /// </param>
     /// <returns>
     /// The item that is removed from the list, or <see langword="nil"/> if the
     /// key is not found.
     /// </returns>
     /// <seealso cref="Delete"/>
     {$Endregion}
     Function Extract(Const Key : String) : THashItem;
     {$Region 'xmldoc'}
     /// <summary>
     /// Sorts the list's items in alphabetical order by their keys.
     /// </summary>
     {$Endregion}
     Procedure Sort;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the number of items in the list.
     /// </summary>
     {$Endregion}
     Property Count : Integer Read fCount;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the item on top of the list.
     /// </summary>
     {$Endregion}
     Property First : THashItem Read fOrderFirst;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the item on bottom of the list.
     /// </summary>
     {$Endregion}
     Property Last : THashItem Read fOrderLast;
     {$Region 'xmldoc'}
     /// <summary>
     /// Lists the items in the list by their unique keys.
     /// </summary>
     /// <exception cref="EKeyNotFoundError">
     /// Occurs when a key is not in the list.
     /// </exception>
     {$Endregion}
     Property Items[Const Key : String] : THashItem Read GetItems; Default;
   End;

 Implementation

  Resourcestring
   SKeyNotFoundError = 'Key ''%s'' is not found';

 { TKeyLookup<TKey, TValue> }

  Constructor TKeyLookup<TKey, TValue>.Create(EqualityComparer : IEqualityComparer<TKey>; Size : Cardinal);
   Var
    BucketSize : Cardinal;
   Begin
    IKey       := EqualityComparer;
    BucketSize := 4;
    While BucketSize < Size Do
     BucketSize := BucketSize Shl 1;
    SetLength(Buckets, BucketSize);
    HashMask := BucketSize - 1;
   End;

  Constructor TKeyLookup<TKey, TValue>.Create(Size : Cardinal);
   Begin
    Create(TEqualityComparer<TKey>.Default, Size);
   End;

  Destructor TKeyLookup<TKey, TValue>.Destroy;
   Begin
    Clear;
    SetLength(Buckets, 0);
    Inherited Destroy;
   End;

 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.AllocateEntry(Const Key : TKey; Const Value : TValue) : PEntry;
   Begin
    // We could use New(Result) but because of Delphi compiler bug, the New
    // standard procedure fails to initialize generic records. The folliwng
    /// three lines are a workaround for this problem.
    GetMem(Result, SizeOf(TEntry));
    Initialize(Result^.Key);    // Key can be long string, variant, or interface
    Initialize(Result^.Value);  // Value can be long string, variant, or interface
    // initialize the new allocated record
    Result^.Key   := Key;
    Result^.Value := Value;
    Result^.Next  := Nil;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.AllocateEntry(Const Key : TKey; Const Value : TValue) : TEntry;
   Begin
    Result       := TEntry.Create;
    Result.Key   := Key;
    Result.Value := Value;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.ReleaseEntry(Entry : PEntry) : PEntry;
   Begin
    Result := Entry^.Next;
    Finalize(Entry^.Key);       // Key can be long string, variant, or interface
    Finalize(Entry^.Value);     // Value can be long string, variant, or interface
    FreeMem(Entry);
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.ReleaseEntry(Entry : TEntry) : TEntry;
   Begin
    Result := Entry.Next;
    Entry.Free;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.LookupBucket(Const Key : TKey) : PPEntry;
   Begin
    Result := @Buckets[IKey.GetHashCode(Key) And HashMask];
    While (Result^ <> Nil) And Not IKey.Equals(Result^^.Key, Key) Do
     Result := @(Result^^.Next);
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.LookupBucket(Const Key : TKey) : Pointer;
   Begin
    Result := @Buckets[IKey.GetHashCode(Key) And HashMask];
    While (TEntry(Result^) <> Nil) And Not IKey.Equals(TEntry(Result^).Key, Key) Do
     Result := @(TEntry(Result^).Next);
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.LookupEntry(Const Key : TKey) : PEntry;
   Begin
    Result := LookupBucket(Key)^;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.LookupEntry(Const Key : TKey) : TEntry;
   Begin
    Result := TEntry(LookupBucket(Key)^);
   End;
 {$ENDIF}

  Procedure TKeyLookup<TKey, TValue>.Clear;
   Var
    i : Integer;
    {$IFDEF COMPILER2010_UP}
    Entry : PEntry;
    {$ELSE}
    Entry : TEntry;
    {$ENDIF}
   Begin
    For i := 0 To Length(Buckets) - 1 Do
     Begin
      Entry := Buckets[i];
      While Entry <> Nil Do
       Entry     := ReleaseEntry(Entry);
      Buckets[i] := Nil;
     End;
   End;

  Procedure TKeyLookup<TKey, TValue>.CopyFrom(Source : TKeyLookup<TKey, TValue>);
   Begin
    Clear;
    Source.ForEach(
    Function(Const Key : TKey; Const Value : TValue) : Boolean
    Begin
    Add(Key, Value);
    Result := True;
    End);
   End;

 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.Add(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Prev  : PPEntry;
    Entry : PEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := Prev^;
    If Entry = Nil Then
     Begin
      Entry  := AllocateEntry(Key, Value);
      Prev^  := Entry;
      Result := True;
     End
    Else
     Result := False;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.Add(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Prev  : Pointer;
    Entry : TEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := TEntry(Prev^);
    If Entry = Nil Then
     Begin
      Entry         := AllocateEntry(Key, Value);
      TEntry(Prev^) := Entry;
      Result        := True;
     End
    Else
     Result := False;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.Update(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Entry : PEntry;
   Begin
    Entry := LookupEntry(Key);
    If Entry <> Nil Then
     Begin
      Entry^.Value := Value;
      Result       := True;
     End
    Else
     Result := False;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.Update(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Entry : TEntry;
   Begin
    Entry := LookupEntry(Key);
    If Entry <> Nil Then
     Begin
      Entry.Value := Value;
      Result      := True;
     End
    Else
     Result := False;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.AddOrUpdate(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Prev  : PPEntry;
    Entry : PEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := Prev^;
    If Entry <> Nil Then
     Begin
      Entry^.Value := Value;
      Result       := True;
     End
    Else
     Begin
      Entry  := AllocateEntry(Key, Value);
      Prev^  := Entry;
      Result := False;
     End;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.AddOrUpdate(Const Key : TKey; Const Value : TValue) : Boolean;
   Var
    Prev  : Pointer;
    Entry : TEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := TEntry(Prev^);
    If Entry <> Nil Then
     Begin
      Entry.Value := Value;
      Result      := True;
     End
    Else
     Begin
      Entry         := TEntry.Create;
      Entry.Key     := Key;
      Entry.Value   := Value;
      TEntry(Prev^) := Entry;
      Result        := False;
     End;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.Remove(Const Key : TKey) : Boolean;
   Var
    Entry : PEntry;
    Prev  : PPEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := Prev^;
    If Entry <> Nil Then
     Begin
      Prev^  := ReleaseEntry(Entry);
      Result := True;
     End
    Else
     Result := False;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.Remove(Const Key : TKey) : Boolean;
   Var
    Prev  : Pointer;
    Entry : TEntry;
   Begin
    Prev  := LookupBucket(Key);
    Entry := TEntry(Prev^);
    If Entry <> Nil Then
     Begin
      TEntry(Prev^) := Entry.Next;
      Entry.Free;
      Result := True;
     End
    Else
     Result := False;
   End;
 {$ENDIF}
 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.Retrieve(Const Key : TKey; Out Value : TValue) : Boolean;
   Var
    Entry : PEntry;
   Begin
    Entry := LookupEntry(Key);
    If Entry <> Nil Then
     Begin
      Value  := Entry^.Value;
      Result := True;
     End
    Else
     Result := False;
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.Retrieve(Const Key : TKey; Out Value : TValue) : Boolean;
   Var
    Entry : TEntry;
   Begin
    Entry := LookupEntry(Key);
    If Entry <> Nil Then
     Begin
      Value  := Entry.Value;
      Result := True;
     End
    Else
     Result := False;
   End;
 {$ENDIF}

  Function TKeyLookup<TKey, TValue>.Exists(Const Key : TKey) : Boolean;
   Begin
    Result := (LookupEntry(Key) <> Nil);
   End;

 {$IFDEF COMPILER2010_UP}

  Function TKeyLookup<TKey, TValue>.ForEach(Callback : TCallback) : Boolean;
   Var
    i     : Integer;
    Entry : PEntry;
   Begin
    Entry := Nil;
    If Assigned(Callback) Then
     Begin
      For i := 0 To Length(Buckets) - 1 Do
       Begin
        Entry := Buckets[i];
        While (Entry <> Nil) And Callback(Entry^.Key, Entry^.Value) Do
         Entry := Entry^.Next;
       End;
     End;
    Result := (Entry = Nil);
   End;
 {$ELSE}

  Function TKeyLookup<TKey, TValue>.ForEach(Callback : TCallback) : Boolean;
   Var
    i     : Integer;
    Entry : TEntry;
   Begin
    Entry := Nil;
    If Assigned(Callback) Then
     Begin
      For i := 0 To Length(Buckets) - 1 Do
       Begin
        Entry := Buckets[i];
        While (Entry <> Nil) And Callback(Entry.Key, Entry.Value) Do
         Entry := Entry.Next;
       End;
     End;
    Result := (Entry = Nil);
   End;
 {$ENDIF}

 { THashItem }

  Function THashItem.GetIndex : Integer;
   Var
    Item : THashItem;
   Begin
    If HashList <> Nil Then
     Begin
      Result := 0;
      Item   := HashList.First;
      While Item <> Nil Do
       Begin
        If Item = Self Then
         Exit;
        Inc(Result);
        Item := Item.Next;
       End;
     End;
    Result := -1;
   End;

  Function THashItem.GetOwner : TPersistent;
   Begin
    Result := HashList;
   End;

  Function THashItem.MoveToFirst : Boolean;
   Begin
    Result := False;
    If HashList <> Nil Then
     Begin
      HashList.MoveItemBefore(Self, HashList.First);
      Result := True;
     End;
   End;

  Function THashItem.MoveToLast : Boolean;
   Begin
    Result := False;
    If HashList <> Nil Then
     Begin
      HashList.MoveItemAfter(Self, HashList.Last);
      Result := True;
     End;
   End;

  Function THashItem.MoveAfter(Item : THashItem) : Boolean;
   Begin
    Result := False;
    If (HashList <> Nil) And (HashList = Item.HashList) Then
     Begin
      HashList.MoveItemAfter(Self, Item);
      Result := True;
     End;
   End;

  Function THashItem.MoveBefore(Item : THashItem) : Boolean;
   Begin
    Result := False;
    If (HashList <> Nil) And (HashList = Item.HashList) Then
     Begin
      HashList.MoveItemBefore(Self, Item);
      Result := True;
     End;
   End;

  Procedure THashItem.Delete;
   Begin
    If HashList <> Nil Then
     HashList.Delete(GetKey)
    Else
     Free;
   End;

 { THashList }

  Constructor THashList.Create(Size : Cardinal);
   Var
    BucketSize : Cardinal;
   Begin
    BucketSize := 4;
    While BucketSize < Size Do
     BucketSize := BucketSize Shl 1;
    SetLength(Buckets, BucketSize);
    HashMask := BucketSize - 1;
   End;

  Destructor THashList.Destroy;
   Begin
    Clear;
    SetLength(Buckets, 0);
    Inherited Destroy;
   End;

  Function THashList.GetItems(Const Key : String) : THashItem;
   Begin
    If Not FindKey(Key, Result) Then
     Raise EKeyNotFoundError.CreateResFmt(@SKeyNotFoundError, [Key]);
   End;

  Procedure THashList.Notify(Item : THashItem; Action : TListNotification);
   Begin
   End;

  Function THashList.HashOf(Const Key : String) : Cardinal;
   Var
    i : Integer;
   Begin
    Result  := 0;
    For i   := 1 To Length(Key) Do
     Result := ((Result Shl 2) Or (Result Shr (SizeOf(Result) * 8 - 2))) Xor Ord(UpCase(Key[i]));
   End;

  Function THashList.Compare(Const Key1, Key2 : String) : Integer;
   Begin
    Result := CompareText(Key1, Key2);
   End;

  Function THashList.FindKey(Const Key : String; Out Item : THashItem) : Boolean;
   Var
    c : Integer;
   Begin
    Result := False;
    Item   := Buckets[HashOf(Key) And HashMask];
    While Item <> Nil Do
     Begin
      c := Compare(Item.GetKey, Key);
      If c < 0 Then
       Item := Item.HashNext
      Else
       Begin
        Result := (c = 0);
        Exit;
       End;
     End;
   End;

  Function THashList.AddKey(Const Key : String; Out Item : THashItem) : Boolean;
   Var
    pNextItem : ^THashItem;
    NextItem  : THashItem;
    c         : Integer;
   Begin
    pNextItem := @Buckets[HashOf(Key) And HashMask];
    NextItem  := pNextItem^;
    While NextItem <> Nil Do
     Begin
      c := Compare(NextItem.GetKey, Key);
      If c < 0 Then
       Begin
        pNextItem := @NextItem.HashNext;
        NextItem  := NextItem.HashNext;
       End
      Else If c = 0 Then
       Begin
        Item   := NextItem;
        Result := False;
        Exit;
       End
      Else
       Break;
     End;
    Item          := GetItemClass.Create(Key);
    pNextItem^    := Item;
    Item.HashList := Self;
    Item.HashNext := NextItem;
    If fOrderFirst = Nil Then
     fOrderFirst := Item;
    If fOrderLast <> Nil Then
     fOrderLast.OrderNext := Item;
    Item.OrderPrev        := fOrderLast;
    Item.OrderNext        := Nil;
    fOrderLast            := Item;
    Inc(fCount);
    Result := True;
   End;

  Function THashList.ExtractKey(Const Key : String; Out Item : THashItem) : Boolean;
   Var
    pNextItem : ^THashItem;
    c         : Integer;
   Begin
    Result    := False;
    pNextItem := @Buckets[HashOf(Key) And HashMask];
    Item      := pNextItem^;
    While Item <> Nil Do
     Begin
      c := Compare(Item.GetKey, Key);
      If c < 0 Then
       Begin
        pNextItem := @Item.HashNext;
        Item      := Item.HashNext;
       End
      Else
       Begin
        If c = 0 Then
         Begin
          TakeItemOut(Item);
          pNextItem^     := Item.HashNext;
          Item.HashList  := Nil;
          Item.HashNext  := Nil;
          Item.OrderPrev := Nil;
          Item.OrderNext := Nil;
          Dec(fCount);
          Result := True;
         End;
        Exit;
       End;
     End;
   End;

  Procedure THashList.TakeItemOut(Item : THashItem);
   Begin
    If Item.OrderPrev <> Nil Then
     Item.OrderPrev.OrderNext := Item.OrderNext
    Else
     fOrderFirst := Item.OrderNext;
    If Item.OrderNext <> Nil Then
     Item.OrderNext.OrderPrev := Item.OrderPrev
    Else
     fOrderLast := Item.OrderPrev;
   End;

  Procedure THashList.MoveItemBefore(Item, ItemAfter : THashItem);
   Begin
    If Item.OrderNext <> ItemAfter Then
     Begin
      TakeItemOut(Item);
      If ItemAfter.OrderPrev <> Nil Then
       ItemAfter.OrderPrev.OrderNext := Item
      Else
       fOrderFirst        := Item;
      Item.OrderPrev      := ItemAfter.OrderPrev;
      Item.OrderNext      := ItemAfter;
      ItemAfter.OrderPrev := Item;
     End;
   End;

  Procedure THashList.MoveItemAfter(Item, ItemBefore : THashItem);
   Begin
    If Item.OrderPrev <> ItemBefore Then
     Begin
      TakeItemOut(Item);
      If ItemBefore.OrderNext <> Nil Then
       ItemBefore.OrderNext.OrderPrev := Item
      Else
       fOrderLast          := Item;
      Item.OrderNext       := ItemBefore.OrderNext;
      Item.OrderPrev       := ItemBefore;
      ItemBefore.OrderNext := Item;
     End;
   End;

  Function THashList.MoveToFirst(Const Key : String) : Boolean;
   Var
    Item : THashItem;
   Begin
    If fOrderFirst <> Nil Then
     If Compare(fOrderFirst.GetKey, Key) <> 0 Then
      If FindKey(Key, Item) Then
       Begin
        MoveItemBefore(Item, fOrderFirst);
        Result := True;
       End
      Else
       Result := False
     Else
      Result := True
    Else
     Result := False;
   End;

  Function THashList.MoveToLast(Const Key : String) : Boolean;
   Var
    Item : THashItem;
   Begin
    If fOrderLast <> Nil Then
     If Compare(fOrderLast.GetKey, Key) <> 0 Then
      If FindKey(Key, Item) Then
       Begin
        MoveItemBefore(Item, fOrderLast);
        Result := True;
       End
      Else
       Result := False
     Else
      Result := True
    Else
     Result := False;
   End;

  Function THashList.MoveBefore(Const Key, KeyAfter : String) : Boolean;
   Var
    Item, ItemAfter : THashItem;
   Begin
    Result := False;
    If FindKey(Key, Item) And FindKey(KeyAfter, ItemAfter) Then
     Begin
      MoveItemBefore(Item, ItemAfter);
      Result := True;
     End;
   End;

  Function THashList.MoveAfter(Const Key, KeyBefore : String) : Boolean;
   Var
    Item, ItemBefore : THashItem;
   Begin
    Result := False;
    If FindKey(Key, Item) And FindKey(KeyBefore, ItemBefore) Then
     Begin
      MoveItemAfter(Item, ItemBefore);
      Result := True;
     End;
   End;

  Function THashList.Exists(Const Key : String) : Boolean;
   Var
    Item : THashItem;
   Begin
    Result := FindKey(Key, Item);
   End;

  Function THashList.Find(Const Key : String) : THashItem;
   Begin
    If Not FindKey(Key, Result) Then
     Result := Nil;
   End;

  Function THashList.Add(Const Key : String) : THashItem;
   Begin
    If AddKey(Key, Result) Then
     Notify(Result, lnAdded);
   End;

  Function THashList.Delete(Const Key : String) : Boolean;
   Var
    Item : THashItem;
   Begin
    Result := False;
    If ExtractKey(Key, Item) Then
     Begin
      Notify(Item, lnDeleted);
      Item.Free;
      Result := True;
     End;
   End;

  Function THashList.Extract(Const Key : String) : THashItem;
   Begin
    If ExtractKey(Key, Result) Then
     Notify(Result, lnExtracted)
    Else
     Result := Nil;
   End;

  Procedure THashList.Clear;
   Var
    Item : THashItem;
    Kill : THashItem;
   Begin
    If fOrderFirst <> Nil Then
     Begin
      Item := fOrderFirst;
      While Item <> Nil Do
       Begin
        Buckets[HashOf(Item.GetKey) And HashMask] := Nil;
        Kill                                      := Item;
        Item                                      := Item.OrderNext;
        Notify(Kill, lnDeleted);
        Kill.Free;
       End;
      fOrderFirst := Nil;
      fOrderLast  := Nil;
      fCount      := 0;
     End;
   End;

  Procedure THashList.Assign(Source : TPersistent);
   Var
    SrcItem : THashItem;
   Begin
    If (Source Is THashList) And (GetItemClass = THashList(Source).GetItemClass) Then
     Begin
      Clear;
      SrcItem := THashList(Source).First;
      While SrcItem <> Nil Do
       Begin
        Add(SrcItem.GetKey).Assign(SrcItem);
        SrcItem := SrcItem.Next;
       End;
     End
    Else
     Inherited Assign(Source);
   End;

  Procedure THashList.Sort;
   Var
    Item       : THashItem;
    NextItem   : THashItem;
    BeforeItem : THashItem;
   Begin
    If fOrderFirst <> Nil Then
     Begin
      Item := fOrderFirst.OrderNext;
      While Item <> Nil Do
       Begin
        NextItem   := Item.Next;
        BeforeItem := fOrderFirst;
        While BeforeItem <> Item Do
         Begin
          If Compare(Item.GetKey, BeforeItem.GetKey) < 0 Then
           Begin
            MoveItemBefore(Item, BeforeItem);
            Break;
           End;
          BeforeItem := BeforeItem.Next;
         End;
        Item := NextItem;
       End;
     End;
   End;

End.
