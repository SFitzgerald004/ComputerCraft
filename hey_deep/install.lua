-- install.lua
local base = "https://raw.githubusercontent.com/SFitzgerald004/ComputerCraft/main/hey_deep/"

local files = {
    { url = base .. "README.md", path = "hey_deep/README.md" },
    { url = base .. "whats_the_box_made_of.dfpwm", path = "hey_deep/whats_the_box_made_of.dfpwm" },
    { url = base .. "zinc_homelander.lua", path = "hey_deep/zinc_homelander.lua" }
}

fs.makeDir("hey_deep")
print("hey deep, what cant i see through?")
print("zinc homelander")
print("correct, and whats the box made of, deep?")
print("...zinc")
print("correct again")

for f, file in ipairs(files) do
    shell.run("wget", file.url, file.path)
end