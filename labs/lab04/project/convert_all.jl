using Literate

for f in readdir("scripts")
    endswith(f, ".jl") || continue
    b = splitext(f)[1]
    p = joinpath("scripts", b)
    
    Literate.script("$p.jl", "scripts"; name=b * "_clean")
    Literate.notebook("$p.jl", "notebooks"; execute=false)
    Literate.markdown("$p.jl", "docs")
    
    md = joinpath("docs", "$b.md")
    write(joinpath("docs", "$b.qmd"), "---\ntitle: $b\njupyter: julia-1.9\n---\n\n" * read(md, String))
    rm(md)
end
