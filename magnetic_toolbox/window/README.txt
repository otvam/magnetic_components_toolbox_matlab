% =================================================================================================
% Computation of winding geometry, inductance, losses, etc.
% =================================================================================================
%
% Define classes for:
%     - the losses of plain and litz conductor
%     - the type of magnetic component (transformer, inductor, etc.)
%     - the geometry of the winding window
%     - the winding losses
%     - the mirroring method for solving magnetostatic problem
%
% =================================================================================================
%
% Folder structure:
%     - window_example - test scripts
%     - window_lib - general methods for winding window computation (mirroring, losses, etc.)
%     - window_class.m - main class for the computation
%     - DATA_STRUCT.txt - documentation of the used data structures
%     - README.txt - this file
%
% =================================================================================================
%
% Getting started:
%     - window_example/test_conductor.m - test of the computation of litz and plain wire losses and geometry
%     - window_example/test_window_inductor.m - complete computation of an inductor with different window types (volume, mass, circuit, losses, etc.)
%     - window_example/test_window_transformer.m - complete computation of a transformer with different window types (volume, mass, circuit, losses, etc.)
%     - window_example/test_mirroring_transformer.m - validation of the mirroring method with a transformer
%     - window_example/test_mirroring_inductor_core.m - validation of the mirroring method with an inductor (core window)
%     - window_example/test_mirroring_inductor_head.m - validation of the mirroring method with an inductor (winding head)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================