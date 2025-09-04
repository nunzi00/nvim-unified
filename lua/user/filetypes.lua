vim.filetype.add({
    extension = {
        neon = "yaml",
        pipeline = "groovy",
    },
    filename = {
        ["docker-compose"] = "dockercompose",
        ["Jenkinsfile"] = "groovy",
    },
})
