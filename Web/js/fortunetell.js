const days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
];

function parseString(params) {

}

function getSteps(datas) {
    return datas.length.toString(2).length;
}

function getStepArrays(datas, steps) {
    var arrs = Array();
    for (let i = 0; i < steps; i++) {
        arrs.push(Array());
    }
    for (let i = 0; i < datas.length; i++) {
        const binaryIndex = (i + 1).toString(2);
        const lastIndex = binaryIndex.length - 1;
        for (let j = lastIndex; j >= 0; j--) {
            const temp = binaryIndex[j];
            if (temp == 1) {
                arrs[lastIndex - j].push(datas[i]);
            }
        }
    }
    return arrs;
}

function myFunction() {
    const steps = getSteps(days);
    const stepArrs = getStepArrays(days, steps);


    for (let step = 0; step < steps; step++) {
        const length = steps - 1;
        const table = document.createElement("table");
        for (let trIndex = 0; trIndex < length; trIndex++) {
            const tr = document.createElement("tr");
            for (let tdIndex = 0; tdIndex < length; tdIndex++) {
                const td = document.createElement("td");
                td.innerHTML = stepArrs[step][trIndex * length + tdIndex];
                tr.appendChild(td);
            }
            table.appendChild(tr);
        }

        let fortunetellDiv = document.getElementById("fortunetellDiv");
        fortunetellDiv.appendChild(table);
    }
}
