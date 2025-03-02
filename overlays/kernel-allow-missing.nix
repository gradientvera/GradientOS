/*
*   Overlay which overrides makeModulesClosure to allow building the kernel with missing modules.
*/
final: prev:
{
  makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
}