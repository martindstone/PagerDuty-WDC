GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${GREEN}Creating scratch org...${NC}"
sfdx force:org:create -f config/project-scratch-def.json -a pd-wdc-scratch -s -d 30

echo -e "${GREEN}Installing Command Center Managed Package...${NC}"
sfdx force:package:install -p 04t5w000005dfhvAAA -w 50

echo -e "${GREEN}Installing Command Center Unmanaged Package...${NC}"
sfdx force:package:install -p 04t5w000005au3o -w 50

echo -e "${GREEN}Installing PagerDuty SFDC integration...${NC}"
sfdx force:package:install -r -p 04t1U000007LjFcQAK -w 30

echo -e "${GREEN}Pushing PD WDC integration source...${NC}"
sfdx force:source:push

#For deploy to non-scratch org
#sfdx force:source:deploy -m ApexClass,CustomObject,LightningComponentBundle,CustomField,StaticResource,SecuritySettings,ApexTrigger,CustomApplication,ContentAsset,FlexiPage,CustomTab,CustomObject

echo -e "${GREEN}Assigning Standard Permission Sets...${NC}"
# Standard Permission Sets
# Workplace Admin
sfdx force:user:permset:assign -n b2w_Admin
# Workplace Global Operations
sfdx force:user:permset:assign -n b2w_GlobalOperations
# Workplace Operations
sfdx force:user:permset:assign -n b2w_Operations

echo -e "${GREEN}Installing Additional Permission Sets...${NC}"
# Extra permission sets with workplace license
sfdx force:source:deploy -p extra-permissionsets

echo -e "${GREEN}Assigning Additional Permission Sets...${NC}"
# Assign extra permission Sets
sfdx force:user:permset:assign -n Workplace_Command_Center_Standard_PermSet_Admin_Full_Access_Cloned
sfdx force:user:permset:assign -n b2w_OperationsExecutiveAddOn
sfdx force:user:permset:assign -n b2w_Workplace_Operations_Addon
sfdx force:user:permset:assign -n b2w_Workplace_Command_Center_Access
sfdx force:user:permset:assign -n b2w_AdminAddOn
sfdx force:user:permset:assign -n b2w_GlobalOperationsExecutiveAddOn
sfdx force:user:permset:assign -n b2w_GlobalOperationsAddOn

echo -e "${GREEN}Opening org...${NC}"
sfdx force:org:open 
