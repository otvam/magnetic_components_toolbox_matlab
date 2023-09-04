% =================================================================================================
% Computation of a magnetic component geometry, equivalent circuit, losses, etc.
% =================================================================================================
%
% Define classes for:
%     - the link between the core and winding window computation
%     - the type of magnetic component (transformer, inductor, etc.)
%     - the geometrical properties of different components
%
% =================================================================================================
%
% Folder structure:
%     - component_example - test scripts
%     - component_lib - general methods for component computation
%     - component_class.m - main class for the computation
%     - DATA_STRUCT.txt - documentation of the used data structures
%     - README.txt - this file
%
% =================================================================================================
%
% Dependency:
%     - 'core' computation library
%     - 'window' computation library
%
% =================================================================================================
%
% Getting started:
%     - core_example/test_component_inductor.m - complete computation of an inductor with C and E core (volume, mass, circuit, losses, etc.)
%     - core_example/test_component_transformer.m - complete computation of a transformer with C and E core (volume, mass, circuit, losses, etc.)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================