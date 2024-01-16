import { StrInput, BoolInput, IntInput, ComputedInput } from "./components.js";
const { createApp } = Vue;

createApp({
  components: {
    StrInput,
    BoolInput,
    IntInput,
    ComputedInput,
  },
  data() {
    return {
      hasBoughtHouse: false,
      hasMaintLoan: false,
      hasSoldHouse: false,
      sellingPrice: 0,
      privateDebt: 0,
    };
  },
  computed: {
    valueResidue() {
      return this.sellingPrice - this.privateDebt;
    },
  },
}).mount("#app");