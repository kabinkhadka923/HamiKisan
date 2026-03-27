@echo off
WHERE /Q pwsh && (
  ECHO YES
) || (
  ECHO NO
)