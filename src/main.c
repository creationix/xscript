#include <stdio.h>

#include "mc.xs.h"

txID fxFindModule(txMachine *the, txID moduleID, txSlot *slot)
{
    txPreparation *preparation = the->preparation;
    char name[PATH_MAX];
    char path[PATH_MAX];
    txBoolean absolute = 0, relative = 0, search = 0;
    txInteger dot = 0;
    txString slash;
    txID id;

    fxToStringBuffer(the, slot, name, sizeof(name));
#if MODDEF_XS_MODS
    if (findMod(the, name, NULL))
    {
        c_strcpy(path, "/");
        c_strcat(path, name);
        c_strcat(path, ".xsb");
        return fxNewNameC(the, path);
    }
#endif

    if (!c_strncmp(name, "/", 1))
    {
        absolute = 1;
    }
    else if (!c_strncmp(name, "./", 2))
    {
        dot = 1;
        relative = 1;
    }
    else if (!c_strncmp(name, "../", 3))
    {
        dot = 2;
        relative = 1;
    }
    else
    {
        relative = 1;
        search = 1;
    }
    if (absolute)
    {
        c_strcpy(path, preparation->base);
        c_strcat(path, name + 1);
        if (fxFindScript(the, path, &id))
            return id;
    }
    if (relative && (moduleID != XS_NO_ID))
    {
        c_strcpy(path, fxGetKeyName(the, moduleID));
        slash = c_strrchr(path, '/');
        if (!slash)
            return XS_NO_ID;
        if (dot == 0)
            slash++;
        else if (dot == 2)
        {
            *slash = 0;
            slash = c_strrchr(path, '/');
            if (!slash)
                return XS_NO_ID;
        }
        if (!c_strncmp(path, preparation->base, preparation->baseLength))
        {
            *slash = 0;
            c_strcat(path, name + dot);
            if (fxFindScript(the, path, &id))
                return id;
        }
#if 0
		*slash = 0;
		c_strcat(path, name + dot);
		if (!c_strncmp(path, "xsbug://", 8)) {
			return fxNewNameC(the, path);
		}
#endif
    }
    if (search)
    {
        c_strcpy(path, preparation->base);
        c_strcat(path, name);
        if (fxFindScript(the, path, &id))
            return id;
    }
    return XS_NO_ID;
}

int main(int argc, char *argv[])
{
    int error = 0;

    xsMachine *machine = fxPrepareMachine(NULL, xsPreparation(), "MagicXScript", NULL, NULL);

    fprintf(stderr, "machine=%p\n", machine);

    xsBeginHost(machine);
    {
        xsVars(2);
        {
            xsTry
            {
                fprintf(stderr, "argc=%d\n", argc);
                if (argc > 1)
                {

                    int argi;
                    xsVar(0) = xsNewArray(0);
                    for (argi = 1; argi < argc; argi++)
                    {
                        xsSetAt(xsVar(0), xsInteger(argi - 1), xsString(argv[argi]));
                    }
                    xsVar(1) = xsCall1(xsGlobal, xsID_require, xsString(argv[1]));
                    fxPush(xsVar(0));
                    fxPushCount(the, 1);
                    fxPush(xsVar(1));
                    fxNew(the);
                    xsResult = fxPop();
                    xsCall0(xsResult, xsID_run);
                }
            }
            xsCatch
            {
                xsStringValue message = xsToString(xsException);
                fprintf(stderr, "### %s\n", message);
                error = 1;
            }
        }
    }
    xsEndHost(the);
    xsDeleteMachine(machine);
    return error;
}