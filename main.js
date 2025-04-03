class EmployeesList {
  constructor() {
    this.list = null;
  }

  createEmployee(name) {
    return { name: name, next: null };
  }

  addEmployee(name) {
    const newEmployee = this.createEmployee(name);
    if (this.list === null) {
      this.list = newEmployee;
      return;
    }

    let currentEmployee = this.list;
    while (currentEmployee.next !== null) {
      currentEmployee = currentEmployee.next;
    }
    const lastEmploee = currentEmployee;
    lastEmploee.next = newEmployee;
  }

  deleteEmployee(name) {
    if (this.list === null) {
      return;
    }

    if (this.list.name === name) {
      this.list = this.list.next;
    }

    let currentEmployee = this.list;
    while (currentEmployee !== null && currentEmployee.next !== null) {
      if (currentEmployee.next.name === name) {
        currentEmployee.next = currentEmployee.next.next;
        return;
      }
      currentEmployee = currentEmployee.next;
    }
  }

  printEmploeesList() {
    const array = [];
    let currentEmployee = this.list;
    while (currentEmployee !== null) {
      array.push(currentEmployee.name);
      currentEmployee = currentEmployee.next;
    }
    console.log(array);
  }

  addEmployeeByPosition(name, position) {
    const newEmployee = this.createEmployee(name);
    let currentEmployee = this.list;
    let currentEmployeePosition = 0;
    while (currentEmployee !== null) {
      currentEmployeePosition++;
      if (currentEmployeePosition === position) {
        newEmployee.next = currentEmployee.next;
        currentEmployee.next = newEmployee;
        return;
      }
      currentEmployee = currentEmployee.next;
    }
  }
}

const newEmployeeList = new EmployeesList();

newEmployeeList.printEmploeesList();
newEmployeeList.addEmployee("Rol");
newEmployeeList.printEmploeesList();
console.log(newEmployeeList);
newEmployeeList.addEmployee("Bob");
newEmployeeList.addEmployee("Smit");
newEmployeeList.printEmploeesList();
console.log(newEmployeeList);
newEmployeeList.addEmployeeByPosition("Nataliia", 1);
newEmployeeList.printEmploeesList();
console.log(newEmployeeList);

console.log(
  "//---------------------------------------------------------------------------"
);

class Collection {
  constructor() {
    this.collection = {}; 
    this.length = 0; 
    this.index = 1; 
  }

  add(value) {
    this.collection[`*${this.index}*`] = value; 
    this.index++;
    this.length++;
  }

  print() {
    console.log(this.collection);
  }

  [Symbol.iterator]() {
    let index2 = 1;
    return {
      next: () => {
        const key = `*${index2}*`;
        const result = {
          value: [key, this.collection[key]],
          done: false,
        };
        if (index2 > this.length) {
          result.done = true;
        }
        index2++;
        return result;
      },
    };
  }
}

const myCollection = new Collection();
myCollection.print();
myCollection.add("first value");
myCollection.print();
myCollection.add("second value");
myCollection.print();
myCollection.add("third value");
myCollection.print();

for (const [key, value] of myCollection) {
  console.log("key:", key, "value:", value);
}
myCollection.add("fourth value");
myCollection.print();
console.log(
  "//---------------------------------------------------------------------------"
);

const checkBrackets = (string) => {
  const object = {
    roundBracketStatus: 0,
    curlyBracketStatus: 0,
    squareBracketStatus: 0,
    moreLessBracketStatus: 0,
    currentOpenBracket: "",
  };

  for (let i = 0; i < string.length; i++) {
    let isValidRound = checkCurrentSymbol(
      object,
      "roundBracketStatus",
      string[i],
      "(",
      ")"
    );
    if (isValidRound === false) {
      return false;
    }

    let isValidCurly = checkCurrentSymbol(
      object,
      "curlyBracketStatus",
      string[i],
      "{",
      "}"
    );
    if (isValidCurly === false) {
      return false;
    }

    let isValidSquare = checkCurrentSymbol(
      object,
      "squareBracketStatus",
      string[i],
      "[",
      "]"
    );
    if (isValidSquare === false) {
      return false;
    }

    let isValidMoreLess = checkCurrentSymbol(
      object,
      "moreLessBracketStatus",
      string[i],
      "<",
      ">"
    );
    if (isValidMoreLess === false) {
      return false;
    }
  }

  return (
    object.roundBracketStatus === 0 &&
    object.curlyBracketStatus === 0 &&
    object.squareBracketStatus === 0 &&
    object.moreLessBracketStatus === 0
  );
};

const checkCurrentSymbol = (object, prop, item, openSymbol, closeSymbol) => {
  if (item === openSymbol) {
    object[prop]++;
    object.currentOpenBracket = openSymbol;
  } else if (item === closeSymbol) {
    if (
      object.currentOpenBracket !== openSymbol &&
      object.currentOpenBracket !== ""
    ) {
      return false;
    }
    object.currentOpenBracket = "";
    object[prop]--;
  }
  if (object[prop] === -1) {
    return false;
  }
  return true;
};

console.log(
  checkBrackets("()"),
  "true",
  checkBrackets("())"),
  "false",
  checkBrackets("(())"),
  "true",
  checkBrackets(")("),
  "false",
  checkBrackets("(()"),
  "false",
  checkBrackets("(())"),
  "true"
);
console.log(
  checkBrackets("{}"),
  "true",
  checkBrackets("{}}"),
  "false",
  checkBrackets("{{}}"),
  "true",
  checkBrackets("}{"),
  "false",
  checkBrackets("{{}"),
  "false",
  checkBrackets("{{}}"),
  "true"
);
console.log(
  checkBrackets("({})"),
  "true",
  checkBrackets("(}{)"),
  "false",
  checkBrackets("{(})"),
  "false",
  checkBrackets("({(())})"),
  "true",
  checkBrackets("(){}(){}"),
  "true",
  checkBrackets("{()()}"),
  "true",
  checkBrackets("{(){}"),
  "false"
);
console.log(
  checkBrackets("[]"),
  "true",
  checkBrackets("(][)"),
  "false",
  checkBrackets("({[]})"),
  "true",
  checkBrackets("({[}])"),
  "false"
);

console.log(
  checkBrackets("<>"),
  "true",
  checkBrackets("(><)"),
  "false",
  checkBrackets("({<}>)"),
  "false",
  checkBrackets("(){}[]<>"),
  "true"
);