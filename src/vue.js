const { createApp } = Vue;
const BoolInput = Vue.defineComponent({
  props: {
    label: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
    modelValue: {
      type: Boolean,
      required: true,
    },
  },
  emits: ["update:modelValue"],
  template: `
        <div>
          <label class="form-label" :for="id">{{ label }}</label>
          <select class="form-control" :id="id" :value="modelValue" @change="$emit('update:modelValue', $event.target.value == 'true')">
            <option :value="true">Yes</option>
            <option :value="false">No</option>
          </select>
        </div>
        `,
});

const IntInput = Vue.defineComponent({
  props: {
    label: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
    modelValue: {
      type: String,
      required: true,
    },
  },
  emits: ["update:modelValue"],
  template: `
      <div>
        <label class="form-label" :for="id">{{ label }}</label>
        <input class="form-control" type="number" :id="id" :value="modelValue" @change="$emit('update:modelValue', $event.target.value)">
      </div>
      `,
});

const StrInput = Vue.defineComponent({
  props: {
    label: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
    modelValue: {
      type: String,
      required: true,
    },
  },
  emits: ["update:modelValue"],
  template: `
        <div>
          <label class="form-label" :for="id">{{ label }}</label>
          <input class="form-control" type="text" :id="id" :value="modelValue" @change="$emit('update:modelValue', $event.target.value)">
        </div>
      `,
});

const ComputedInput = Vue.defineComponent({
  props: {
    label: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: true,
    },
  },
  template: `
        <div>
          <label class="form-label" :for="id">{{ label }}</label>
          <input class="form-control" type="text" :id="id" :value="value">
        </div>
      `,
});

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
