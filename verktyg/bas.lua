bas = {}

local tickande = {}
local signaler = {}
local grafik = {}
local scheman = {}
local tid = 0

-- Kör alla signaler som har kommit in sen senast
function bas.hanteraSignaler()
    repeat
        for signal, meddelande in pairs(signaler) do
            -- print(signaler[meddelande])
            signal(unpack(meddelande))
        end
        signaler = {}
        coroutine.yield()
    until false
end

-- Anropa en funktion med ... parametrar
function bas.skickaSignal(signal, ...)
    -- params: function, ...
    signaler[signal] = {...}
end

-- Starta en coroutine
function bas.starta(objekt)
    -- params: function
    objekt = coroutine.create(objekt)
    table.insert(tickande, objekt)
end

-- Kör alla coroutines en gång
function bas.tick()
    tid = tid + love.timer.getDelta()
    for _, objekt in pairs(tickande) do
        coroutine.resume(objekt)
    end
end

-- DEFECT: 2 calls scheduled at the same time will overwrite eachother
-- Schemalägg ett funktionsanrop
function bas.repetera(funktion, paus, repetera, ...)
    -- params: function, integer, boolean
    scheman[tid + paus] = {
        ["funktion"]=funktion, ["paus"]=paus, ["repetera"]=repetera, ["params"]={...}
    }
end

-- Kör Schemalagda funktioner
function bas.repeteraAlla()
    repeat
        for i, schema in pairs(scheman) do
            if i <= tid then
                schema["funktion"](unpack(schema["params"]))
                if schema["repetera"] then
                    bas.repetera(
                        schema["funktion"], schema["paus"], schema["repetera"], unpack(schema["params"])
                    )
                end
                scheman[i] = nil
            end
        end
        coroutine.yield()
    until false
end

-- Uppdatera grafik
function bas.uppdateraGrafik()
    repeat
        for sprite, funktion in pairs(grafik) do
            funktion(sprite)
        end
        coroutine.yield()
    until false
end

function bas.startaGrafik(sprite, funktion)
    -- params: sprite med funktionen uppdatera
    grafik[sprite]=funktion
end

function bas.raderaGrafik(sprite)
    grafik[sprite] = nil
end
