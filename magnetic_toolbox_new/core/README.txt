% =================================================================================================
% Computation of core geometry, reluctance, inductance, losses, etc.
% =================================================================================================
%
% Define classes for:
%     - the magnetic core material parameter
%     - the type of magnetic component (transformer, inductor, etc.)
%     - the geometry of the core
%     - the core losses
%     - the reluctance method for solving magnetic circuits
%
% =================================================================================================
%
% Folder structure:
%     - core_example - test scripts
%     - core_lib - general methods for core computation (core material and reluctance model, etc.)
%     - core_class.m - main class for the computation
%     - DATA_STRUCT.txt - documentation of the used data structures
%     - README.txt - this file
%
% =================================================================================================
%
% Getting started:
%     - core_example/test_core_material.m - test of the computation of the material parameters (mu, steinmetz, losses, etc.)
%     - core_example/test_reluctance_method.m - test of the reluctance solver (reluctance, flux, inductance, etc.)
%     - core_example/test_core_inductor.m - complete computation of an inductor with C and E core (volume, mass, circuit, losses, etc.)
%     - core_example/test_core_transformer.m - complete computation of a transformer with C and E core (volume, mass, circuit, losses, etc.)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================