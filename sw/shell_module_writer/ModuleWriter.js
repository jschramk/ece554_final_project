const range = document.querySelector("#tableWidth");
const input = document.querySelector("#input");
const output = document.querySelector("#output");
const convertButton = document.querySelector("#convertButton");
const downloadButton = document.querySelector("#downloadButton");
const clearButton = document.querySelector("#clearButton");
const tableWidthOutput = document.querySelector("#tableWidthOutput");
const moduleNameInput = document.querySelector("#moduleNameInput");

var tableCols = 2;//parseInt(range.value);
var modules = {};

function download(filename, text) {

    var element = document.createElement('a');

    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));

    element.setAttribute('download', filename);

    element.style.display = 'none';

    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);

}

clearButton.addEventListener('click', (e) => {

    input.value = "";
    moduleNameInput.value = "";

});

downloadButton.addEventListener("click", (e) => {

    for(let name of Object.keys(modules)) {

        download(name + ".sv", modules[name]);

    }

});

convertButton.addEventListener("click", (e) => {

    // read input data from text box

    let text = input.value.trim();

    let entries = text.split(/[\\s]*\n+[\\s]*/);

    console.log(entries);

    let tableRows = Math.ceil(entries.length / tableCols);

    let table = [tableRows];

    for (let i = 0; i < tableRows; i++) {

        let row = [];

        for (let j = 0; j < tableCols; j++) {

            row.push(entries[i * tableCols + j]);

        }

        table[i] = row;

    }

    console.log(table);

    // process data to get port information

    let inputs = [];
    let outputs = [];

    for (let row = 0; row < table.length; row++) {

        let columnData = table[row];

        let port = columnData[0];


        switch (columnData[1].toLowerCase()) {

            case "i": {
                inputs.push(port);
                break;
            }

            case "o": {
                outputs.push(port);
                break;
            }

            default: {
                console.error("invalid port direction: " + columnData[1]);
                break;
            }

        }


    }

    // write string for module

    let moduleName = moduleNameInput.value.trim();

    if (moduleName.length == 0) {
        alert("Please enter a module name");
        return;
    }

    let portStrings = [];

    inputs.map((value) => {
        portStrings.push("    input " + value)
    });

    outputs.map((value) => {
        portStrings.push("    output " + value)
    });

    let moduleString = `module ${moduleName} (\n${portStrings.join(",\n")}\n);\n\n\nendmodule`;

    output.value = moduleString;

    modules[moduleName] = moduleString;

});

/*
range.addEventListener("input", (e) => {

    tableCols = parseInt(e.target.value);

    tableWidthOutput.innerHTML = tableCols;

});*/