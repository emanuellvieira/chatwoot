<template>
  <div class="contact-details">
    <div class="contact-header">
      <div class="contact-avatar">
        <img
          v-if="contact.avatar_url"
          :src="contact.avatar_url"
          :alt="contact.name"
          class="avatar-image"
        />
        <div v-else class="avatar-placeholder">
          {{ contactInitials }}
        </div>
      </div>
      <div class="contact-info">
        <h3 class="contact-name">{{ contact.name || 'Sem nome' }}</h3>
        <p v-if="contact.email" class="contact-email">
          <i class="icon-mail"></i>
          {{ contact.email }}
        </p>
        <p v-if="contact.phone_number" class="contact-phone">
          <i class="icon-phone"></i>
          {{ contact.phone_number }}
        </p>
      </div>
    </div>
    
    <!-- HubSpot Link -->
    <hubspot-link
      v-if="hubspotIntegrationEnabled"
      :contact="contact"
    />
    
    <!-- Additional Attributes -->
    <div v-if="hasAdditionalAttributes" class="additional-attributes">
      <h4>Informações Adicionais</h4>
      <div class="attributes-grid">
        <div
          v-for="(value, key) in filteredAdditionalAttributes"
          :key="key"
          class="attribute-item"
        >
          <span class="attribute-label">{{ formatAttributeLabel(key) }}:</span>
          <span class="attribute-value">{{ value }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import HubspotLink from './HubspotLink.vue';

export default {
  name: 'ContactDetails',
  components: {
    HubspotLink,
  },
  props: {
    contact: {
      type: Object,
      required: true,
    },
  },
  computed: {
    contactInitials() {
      if (!this.contact.name) return '?';
      return this.contact.name
        .split(' ')
        .map(name => name.charAt(0))
        .join('')
        .toUpperCase()
        .slice(0, 2);
    },
    hasAdditionalAttributes() {
      return this.contact.additional_attributes && 
             Object.keys(this.filteredAdditionalAttributes).length > 0;
    },
    filteredAdditionalAttributes() {
      if (!this.contact.additional_attributes) return {};
      
      const attrs = { ...this.contact.additional_attributes };
      
      // Remove HubSpot specific attributes as they're handled separately
      delete attrs.hubspot_id;
      delete attrs.hubspot_url;
      
      return attrs;
    },
    hubspotIntegrationEnabled() {
      return this.$store.getters['accounts/hubspotIntegrationEnabled'];
    },
  },
  methods: {
    formatAttributeLabel(key) {
      const labels = {
        company: 'Empresa',
        job_title: 'Cargo',
        address: 'Endereço',
        city: 'Cidade',
        state: 'Estado',
        zip: 'CEP',
        country: 'País',
      };
      
      return labels[key] || key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
    },
  },
};
</script>

<style lang="scss" scoped>
.contact-details {
  padding: 1rem;
}

.contact-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.contact-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background-color: #e0e0e0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: bold;
  color: #666;
}

.contact-info {
  flex: 1;
}

.contact-name {
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.contact-email,
.contact-phone {
  margin: 0.25rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #666;
  font-size: 0.875rem;
}

.additional-attributes {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
}

.additional-attributes h4 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  font-weight: 600;
}

.attributes-grid {
  display: grid;
  gap: 0.5rem;
}

.attribute-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.attribute-label {
  font-weight: 500;
  color: #333;
}

.attribute-value {
  color: #666;
  text-align: right;
}
</style> 