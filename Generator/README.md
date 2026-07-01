This contains the "Generator" command line tool that consumes the
Foundry extension_api.json file and produces the Swift bindings for it.

When used with the FoundrySwift package, this is automatically
invoked with the Foundry 4.6 API description and will generate
the documentation.

It can optionally produce inline documentation if you have Foundry
installed locally, but you currently must edit the main.swift
source file to point it to your Foundry documentation checkout.
