<template>
  <v-container>
    <v-row class="text-center">
      <v-col cols="12">
          <v-select label="Field separator" :items="fieldSeparators"
            v-model="fieldSeparator" v-on:input="onChange($event)" />
          <v-textarea id="input" v-on:input="onChange($event)" :autofocus="true"
            rows="10" v-model="input"
            :error-messages="errors"
            label="CSV formatted BOM list" />
          <v-select label="RefDes column" v-model="refColumn" :items="columns"
            v-on:change="onChange($event)" />
          <v-select label="Quantity column" v-model="qtyColumn" :items="columns"
            v-on:change="onChange($event)" />
          <v-btn v-on:click="copyText">Copy result clipboard</v-btn>
          <v-textarea id="output" rows="10" label="Splitted BOM List"
            :readonly="true" v-model="output"
            hint="Here you see the result. You cannot edit the result. But you can copy it." />
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  const Papa = require('papaparse');

  export default {
    name: 'BOM',

    data: () => ({
        fieldSeparators: [
            { text: "Tab", value: "\t" },
            { text: "Space", value: " " },
            { text: ";", value: ";" },
        ],
        fieldSeparator: "\t",
        input: "",
        errors: [],
        columns: [],
        refColumn: "",
        qtyColumn: "",
        output: "",
    }),
    methods: {
        splitRefString(str) {
            const splitted = str.split(",");
            let res = [];
            // Split the following string:
            // "abc123-125, c4" into:
            // ["abc123", "abc124", "abc125", "c4"]
            const pattern = /([a-zA-Z]+)(\d+)\s*-\s*([a-zA-Z]*)(\d+)/;
            for (const c of splitted) {
                const ct = c.trim();
                if (!ct.length) {
                    continue;
                }
                else if (pattern.test(ct)) {
                    const regexpRes = pattern.exec(ct);
                    for (let i = parseInt(regexpRes[2]); i <= parseInt(regexpRes[4]); i++) {
                        res.push(regexpRes[1] + String(i));
                    }
                }
                else {
                    res.push(ct);
                }
            }
            return res;
        },
        onChange() {
            this.update();
        },
        update() {
            const config = {
                delimiter: this.fieldSeparator
            };
            const res = Papa.parse(this.input, config);
            this.errors = res.errors;
            this.columns = res.data[0];

            const refColumnDefault = "RefDes";
            if (!this.refColumn && this.columns.indexOf(refColumnDefault) >= 0) {
                this.refColumn = refColumnDefault;
            }
            else if (this.refColumn && this.columns.indexOf(this.refColumn) < 0) {
                this.refColumn = "";
            }

            const qtyColumnDefault = "Qty";
            if (!this.qtyColumn && this.columns.indexOf(qtyColumnDefault) >= 0) {
                this.qtyColumn = qtyColumnDefault;
            }
            else if (this.qtyColumn && this.columns.indexOf(this.qtyColumn) < 0) {
                this.qtyColumn = "";
            }

            if (!this.refColumn || !this.qtyColumn || res.errors.length || !res.data.length) {
                this.output = "";
                return;
            }
            const ref = res.data[0].indexOf(this.refColumn);
            const qty = res.data[0].indexOf(this.qtyColumn);
            let out = [];
            for (const row of res.data) {
                if (row.length < ref || row.length < qty || !parseInt(row[qty])) {
                    out.push(row);
                    continue;
                }
                const elems = this.splitRefString(row[ref]);
                if (parseInt(row[qty]) == elems.length) {
                    for (const elem of elems) {
                        let rowToAdd = [...row];
                        rowToAdd[qty] = "1";
                        rowToAdd[ref] = elem;
                        out.push(rowToAdd);
                    }
                }
                else {
                    out.push([`Error: Column ${this.qtyColumn} is '${row[qty]}' but should be '${elems.length}'`]);
                }
            }
            this.output = Papa.unparse(out, config);
        },
        copyText() {
            document.getElementById('output').select();
            document.execCommand("copy");
        }
    }
  }
</script>
