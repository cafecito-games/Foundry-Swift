# Memory Management in FoundrySwift

FoundrySwift surfaces various Foundry types into the Swift universe in various ways:

- Structures: things like ``Rect2`` or ``Plane``.
- Simple classes that have their lifecyle managed in a way similar to Swift 
(``Callable``, ``VariantArray``, ``VariantDictionary``) 
- <doc:Variants>: these are objects that can wrap every other Foundry type and are
  used to pass values around in Foundry.
- ``Object``-derived classes: this is what makes up the bulk of Foundry classes, things like ``Node``, ``Resource``, ``Image`` and so on.

## Object-derived Classes

In FoundrySwift, the base type that bridges Foundry objects and the Swift world
happens in the ``Object`` class (technically, ``Wrapped``, but that is
historical detail that is not very important).

Object-derived classes expose the functionality of the type in Foundry and they
themselves only contain one value, a pointer to the native Foundry object (we call
this the `handle`).   

FoundrySwift ensures that for every Foundry object instance, a single object is
surfaced in the Swift world.   This means that if two FoundrySwift objects have
different addresses, they are also different Foundry objects.   This did not use
to be the case in the early days of FoundrySwift.

Foundry has a few different rules for how memory must be managed for subclasses of
``Object``, depending on which type of object you are dealing with.   The
hierarchy of types, based on the rules that are used are as follows:

- ``Object``
  - ``RefCounted``
    - ``Resource``
  - ``Node``

### Object Classes

Subclasses of ``Object`` that are not ``RefCounted`` or ``Node`` must be
manually released by calling ``Object/free()``. 

### Node Classes

Subclasses of ``Node`` are a bit different.   They are not reference counted,
and they are expected to be added to a ``Scene``.   When the scene is destroyed,
so are all the objects in it.   If you create ``Node`` objects that you do not
add to a ``Scene``, you are responsible for releasing them, and you do so by
calling the ``Node/queueFree()`` method.   This is similar to how you would do
it in Foundry.

### RefCounted Classes

Subclasses of ``RefCounted`` include popular base classes like ``Resource``, and
thus a large number of interesting classes like ``Texture``, ``AudioStream`` and
others.   FoundrySwift is able to manage the lifecycle of every ``RefCounted`` in
a way similar to Swift - that is, when the last reference to the object goes
away, the object is deallocated.

## Invalidated Objects

Unlike RefCounted objects, everything else that derives from ``Object`` can
still have a Swift-level object that points to an object that has been released.

If you keep a reference to these objects, you need to ensure that they remain
valid when Foundry calls you back, as the objects might have been freed behind
your back - so you must call ``Object/isValid`` to ensure that the object
remains valid.   

