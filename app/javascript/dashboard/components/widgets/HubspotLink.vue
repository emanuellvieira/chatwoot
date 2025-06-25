<template>
  <div v-if="hubspotUrl" class="hubspot-link-container">
    <a
      :href="hubspotUrl"
      target="_blank"
      rel="noopener noreferrer"
      class="hubspot-link"
      :title="$t('HUBSPOT.VIEW_IN_HUBSPOT')"
    >
      <i class="icon-hubspot"></i>
      {{ $t('HUBSPOT.VIEW_IN_HUBSPOT') }}
    </a>
  </div>
</template>

<script>
export default {
  name: 'HubspotLink',
  props: {
    contact: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hubspotUrl() {
      const hubspotId = this.contact.additional_attributes?.hubspot_id;
      return hubspotId ? `https://app.hubspot.com/contacts/${hubspotId}` : null;
    },
  },
};
</script>

<style lang="scss" scoped>
.hubspot-link-container {
  margin-top: 0.5rem;
}

.hubspot-link {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background-color: #ff7a59;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
  transition: background-color 0.2s ease;

  &:hover {
    background-color: #e65a3a;
    text-decoration: none;
    color: white;
  }

  .icon-hubspot {
    width: 16px;
    height: 16px;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='white'%3E%3Cpath d='M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z'/%3E%3C/svg%3E");
    background-size: contain;
    background-repeat: no-repeat;
  }
}
</style> 