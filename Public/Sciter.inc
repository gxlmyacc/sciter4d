{$DEFINE WINDOWS}
{$DEFINE HAS_TISCRIPT}

{$IFDEF CPUX86}
  {$DEFINE UseLogHelper}
{$ENDIF CPUX86}

{$ALIGN ON}
{$MINENUMSIZE 4}
{$Z4}

{$IF CompilerVersion >= 14.0}
  {$DEFINE DELPHI6UP}
  {$IF CompilerVersion >= 15.0}
    {$DEFINE DELPHI7UP}
    {$IF CompilerVersion >= 18.5}
      {$DEFINE DELPHI2007UP}
      {$IF CompilerVersion >= 20.0}
        {$DEFINE DELPHI2009UP}
        {$IF CompilerVersion >= 21.0}
          {$DEFINE DELPHI2010UP}
          {$IF CompilerVersion >= 22.0}
            {$DEFINE DELPHIXEUP}
            {$IF CompilerVersion >= 23.0}
              {$DEFINE DELPHIXE2UP}
              {$IF CompilerVersion >= 24.0}
                {$DEFINE DELPHIXE3UP}
                {$IF CompilerVersion >= 25.0}
                  {$DEFINE DELPHIXE4UP}
                  {$IF CompilerVersion >= 26.0}
                    {$DEFINE DELPHIXE5UP}
                    {$IF CompilerVersion >= 27.0}
                      {$DEFINE DELPHIXE6UP}
                      {$IF CompilerVersion >= 28.0}
                        {$DEFINE DELPHIXE7UP}
                        {$IF CompilerVersion >= 29.0}
                          {$DEFINE DELPHIXE8UP}
                          {$IF CompilerVersion >= 30.0}
                            {$DEFINE DELPHI10UP}
                            {$IF CompilerVersion >= 31.0}
                              {$DEFINE DELPHI10.1UP}
                            {$IFEND}
                          {$IFEND}
                        {$IFEND}
                      {$IFEND}
                    {$IFEND}
                  {$IFEND}
                {$IFEND}
              {$IFEND}
            {$IFEND}
          {$IFEND}
        {$IFEND}
      {$IFEND}
    {$IFEND}
  {$IFEND}
{$IFEND}
