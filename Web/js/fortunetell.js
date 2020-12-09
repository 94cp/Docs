const days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
];

function parseString(params) {
    
}

function getSteps(datas) {
    return datas.length.toString(2).length;
}

function gets(datas) {
    const steps = getSteps(datas);
    var arrs = Array();
    for (let i = 0; i < steps; i++) {
        arrs.push(Array());
    }
    for (let i = 0; i < datas.length; i++) {
        const binaryIndex = (i + 1).toString(2);
        for (let j = binaryIndex.length - 1; j >= 0; j--) {
            const temp = binaryIndex[j];
            if (temp == 1) {
                arrs[j].push(datas[i]);
            }
        }
    }
    return arrs;
}

function myFunction(){
	var x = document.getElementById("demo");
	x.innerHTML= gets(days);
}
// https://www.cnblogs.com/leftshine/p/GuessBirthday.html