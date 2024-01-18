export const BoolInput = Vue.defineComponent({
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

export const IntInput = Vue.defineComponent({
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
      type: Number,
      required: true,
    },
  },
  emits: ["update:modelValue"],
  template: `
      <div>
        <label class="form-label" :for="id">{{ label }}</label>
        <input 
          class="form-control" 
          pattern="[0-9]{1,10}" 
          type="number" :id="id" 
          :value="modelValue" 
          @change="$emit('update:modelValue', ($event.target.value === "" ? 0 : parseInt($event.target.value, 10)))">
      </div>
      `,
});

export const StrInput = Vue.defineComponent({
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

export const ComputedInput = Vue.defineComponent({
  props: {
    label: {
      type: String,
      required: true,
    },
    value: {
      required: true,
    },
    id: {
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
