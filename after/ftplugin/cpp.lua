local luasnip = require("luasnip")
local extras = require("luasnip.extras")

local s = luasnip.snippet
local i = luasnip.insert_node
local t = luasnip.text_node
local f = luasnip.function_node
local rep = extras.rep

--- Create a snippet for a Traverse/WalkUpFrom/Visit member
---@param kind string
local function clang_rav_member(kind)
    local map = {
        traverse = "Traverse",
        walkupfrom = "WalkUpFrom",
        visit = "Visit",
    }
    return s(kind, {
        t("bool " .. map[kind]),
        i(1),
        t("("),
        f(function(args, _, _) return args[1][1] end, { 1 }),
        t("* "),
        i(2),
        t({ ") {", "" }),
        i(3),
        t({ "", "\treturn true;", "}" })
    })
end

luasnip.add_snippets("cpp", {
    s("rav", {
        t("class "),
        i(1, "Visitor"),
        t(" : public clang::RecursiveASTVisitor<"),
        rep(1),
        t({ "> {", "public:", "\tusing Base = clang::RecursiveASTVisitor<" }),
        rep(1),
        t({ ">;", "", "\t" }),
        i(2),
        t({ "", "};" })
    }),
    clang_rav_member("traverse"),
    clang_rav_member("walkupfrom"),
    clang_rav_member("visit"),
})
