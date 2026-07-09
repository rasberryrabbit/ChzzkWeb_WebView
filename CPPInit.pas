    unit CPPInit;
     
    {$mode ObjFPC}{$H+}
    {$Assertions ON}
     
    interface
     
    implementation
      {$if defined(WINDOWS) and not defined(MinGW)}
        uses windows;
      {$EndIf}
     
      {$If defined(MinGW)}
        procedure __main(); cdecl; external;
      {$ElseIf defined(WINDOWS)} // MSVC
        {$IfDef CPU64}
          function CRT_INIT(hinstDLL: HINST; fdwReason: DWORD; lpReserved: PtrInt): LongBool; stdcall;
            external name '_CRT_INIT';
        {$else}
          function CRT_INIT(hinstDLL: HINST; fdwReason: DWORD; lpReserved: PtrInt): LongBool; stdcall;
            external name '__CRT_INIT@12';
        {$EndIf}
      {$EndIf}
     
    initialization
      {$If defined(MinGW)}
      __main();
      {$ElseIf defined(WINDOWS)} // MSVC
      Assert(CRT_INIT(HINSTANCE, DLL_PROCESS_ATTACH, dllparam), 'CRT_INIT FAILED');
      {$EndIf}
     
    {$if defined(WINDOWS) and not defined(MinGW)}
    finalization
      CRT_INIT(HINSTANCE, DLL_PROCESS_DETACH, dllparam);
    {$EndIf}
    end.
     