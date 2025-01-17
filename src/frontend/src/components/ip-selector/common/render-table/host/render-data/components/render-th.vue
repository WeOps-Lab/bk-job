<template>
    <th
        ref="rootRef"
        :class="{
            [`host-column-${columnKey}`]: true,
        }"
        :data-date="Date.now()"
        @mousedown="handleMouseDown"
        @mousemove="handleMouseMove">
        <div class="cell">
            <div class="cell-text">
                <RenderThCell :config="columnConfig" />
            </div>
            <filter-select
                v-if="columnConfig.filter"
                :data="columnConfig.filter" />
        </div>
    </th>
</template>
<script setup>
    import {
        computed,
        onMounted,
        ref,
    } from 'vue';

    import Manager from '../../../../../manager';
    import tableColumnConfig from '../../column-config';

    import FilterSelect from './filter-select.vue';
    import RenderThCell from './render-th-cell.js';

    const props = defineProps({
        columnKey: {
            type: String,
            required: true,
        },
        columnWidthCallback: {
            type: Function,
        },
        index: {
            type: Number,
            required: true,
        },
    });
    const emits = defineEmits([
        'mousedown',
        'mousemove',
    ]);

    const { hostTableCustomColumnList } = Manager.config;

    const tableCustomColumnConfig = hostTableCustomColumnList.reduce((result, item) => ({
        ...result,
        [item.key]: item,
    }), {});

    const rootRef = ref();
    const columnConfig = computed(() => {
        if (tableColumnConfig[props.columnKey]) {
            return tableColumnConfig[props.columnKey];
        } else if (tableCustomColumnConfig[props.columnKey]) {
            return tableCustomColumnConfig[props.columnKey];
        }
        return null;
    });

    const handleMouseDown = (event) => {
        emits('mousedown', event);
    };

    const handleMouseMove = (event) => {
        emits('mousemove', event);
    };

    onMounted(() => {
        rootRef.value.style.width = props.columnWidthCallback
                ? props.columnWidthCallback(props.index)
                : columnConfig.value.width;
    });
</script>
