// Jenkinsfile
pipeline {
    agent any

    environment {
        SSH_CREDENTIALS_ID = 'customer-vm-ssh-key'
        AWS_REGION = 'us-east-1'
        TERRAFORM_CUSTOMER_TEMPLATE_PATH = "./terraform_customer_vm_template"
        ANSIBLE_PLAYBOOKS_PATH = "./ansible_playbooks"
        CUSTOMER_VM_AMI_ID = 'ami-053b0d53c279acc90' // THAY THẾ BẰNG AMI UBUNTU GỐC MỚI NHẤT
        CUSTOMER_VM_INSTANCE_TYPE = 't2.micro'
        CUSTOMER_VM_KEY_PAIR_NAME = 'nguyenp-key-pair' // THAY THẾ
        CUSTOMER_VM_SUBNET_ID = 'subnet-0b49e3eae1288df2f' // THAY THẾ bằng Public Subnet ID
        NFS_SERVER_IP = "54.163.128.67" // THAY THẾ bằng IP public của NFS server
        NFS_SHARE_PATH = "/srv/nfs/shared_mail_data"
        NAGIOS_SERVER_PRIVATE_IP = "10.0.1.172" // THAY THẾ bằng IP private của Nagios server
    }

    parameters {
        string(name: 'CUSTOMER_NAME', defaultValue: '', description: 'Tên định danh khách hàng (vd: FPT, Viettel)')
        string(name: 'CUSTOMER_DOMAIN', defaultValue: '', description: 'Tên miền của khách hàng (vd: fpt.com, viettel.net)')
        string(name: 'CUSTOMER_EMAIL_USER', defaultValue: 'admin', description: 'Tên user email đầu tiên (vd: admin, support)')
        password(name: 'CUSTOMER_EMAIL_PASSWORD', defaultValue: '', description: 'Mật khẩu cho user email đầu tiên')
    }

    stages {
        stage('1. Chuẩn bị Workspace cho Khách hàng') {
            steps {
                script {
                    def customerWorkspacePath = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_terraform"
                    sh "rm -rf ${customerWorkspacePath}"
                    sh "mkdir -p ${customerWorkspacePath}"
                    sh "cp -R ${env.TERRAFORM_CUSTOMER_TEMPLATE_PATH}/* ${customerWorkspacePath}/"
                    writeFile file: "${customerWorkspacePath}/terraform.tfvars", text: """
                    aws_region                 = "${env.AWS_REGION}"
                    customer_name              = "${params.CUSTOMER_NAME}"
                    customer_vm_ami_id         = "${env.CUSTOMER_VM_AMI_ID}"
                    customer_vm_instance_type  = "${env.CUSTOMER_VM_INSTANCE_TYPE}"
                    key_pair_name              = "${env.CUSTOMER_VM_KEY_PAIR_NAME}"
                    subnet_id                  = "${env.CUSTOMER_VM_SUBNET_ID}"
                    project_name_tag           = "EmailServiceProject"
                    """
                    echo "Đã chuẩn bị workspace và file terraform.tfvars cho khách hàng ${params.CUSTOMER_NAME}"
                }
            }
        }

        stage('2. Tạo Máy chủ Khách hàng (Terraform)') {
            steps {
                script {
                    def customerWorkspacePath = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_terraform"
                    dir(customerWorkspacePath) {
                        sh "terraform init"
                        sh "terraform plan -out=tfplan"
                        // input message: "Xác nhận tạo máy chủ cho ${params.CUSTOMER_NAME}?", submitter: "admins"
                        sh "terraform apply -auto-approve tfplan"
                        def terraformOutput = sh(script: "terraform output -json", returnStdout: true).trim()
                        def jsonOutput = readJSON text: terraformOutput
                        env.CUSTOMER_VM_PUBLIC_IP = jsonOutput.customer_vm_public_ip.value
                        env.CUSTOMER_VM_PRIVATE_IP = jsonOutput.customer_vm_private_ip.value
                        echo "Máy chủ cho ${params.CUSTOMER_NAME} đã được tạo với IP Public: ${env.CUSTOMER_VM_PUBLIC_IP}, IP Private: ${env.CUSTOMER_VM_PRIVATE_IP}"
                    }
                }
            }
        }

        stage('3. Cấu hình Máy chủ Khách hàng (Ansible)') {
            // Điều kiện when phải được đặt ở cấp độ stage
            when {
                expression { env.CUSTOMER_VM_PUBLIC_IP != null && env.CUSTOMER_VM_PUBLIC_IP != "" }
            }
            steps {
                // Sử dụng withCredentials để bao bọc các bước cần credentials
                withCredentials([sshUserPrivateKey(credentialsId: env.SSH_CREDENTIALS_ID, keyFileVariable: 'ANSIBLE_SSH_KEY_FILE')]) {
                    script {
                        echo "Bắt đầu cấu hình Ansible cho ${params.CUSTOMER_NAME} tại IP ${env.CUSTOMER_VM_PUBLIC_IP}"
                        echo "Sử dụng key file: ${ANSIBLE_SSH_KEY_FILE}"
                        // Đợi một chút để SSH sẵn sàng trên máy chủ mới
                        sleep(60) // 60 giây

                        def inventoryContent = """
                        [mail_server_customer]
                        ${env.CUSTOMER_VM_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${ANSIBLE_SSH_KEY_FILE} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
                        """
                        def ansibleInventoryFile = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_inventory.ini"
                        writeFile file: ansibleInventoryFile, text: inventoryContent
                        echo "Đã tạo file inventory: ${ansibleInventoryFile}"

                        dir(env.ANSIBLE_PLAYBOOKS_PATH) {
                         sh """
ansible-playbook -i '${ansibleInventoryFile}' setup_mail_server.yml \\
    -e 'customer_domain=${params.CUSTOMER_DOMAIN}' \\
    -e 'customer_email_user=${params.CUSTOMER_EMAIL_USER}' \\
    -e 'customer_email_password=${params.CUSTOMER_EMAIL_PASSWORD}' \\
    -e 'nfs_server_ip=${env.NFS_SERVER_IP}' \\
    -e 'nfs_share_path=${env.NFS_SHARE_PATH}' \\
    -e 'nagios_server_private_ip=${env.NAGIOS_SERVER_PRIVATE_IP}' \\
    -e 'target_host_private_ip=${env.CUSTOMER_VM_PRIVATE_IP}' \\
    -e 'target_host_public_ip=${env.CUSTOMER_VM_PUBLIC_IP}'
"""
                        }
                        echo "Đã cấu hình máy chủ cho ${params.CUSTOMER_NAME} bằng Ansible."
                    } // Đóng script của withCredentials
                } // Đóng withCredentials
            } // Đóng steps của stage 3
        } // Đóng stage 3

        // stage('4. Cập nhật Nagios Server') { ... }
        // stage('5. Thông báo Kết quả cho n8n') { ... }
    } // Đóng stages

    post {
        always {
            echo 'Hoàn thành pipeline onboarding khách hàng.'
            // cleanWs()
        }
        success {
            echo "Pipeline cho ${params.CUSTOMER_NAME} hoàn thành thành công."
        }
        failure {
            echo "Pipeline cho ${params.CUSTOMER_NAME} thất bại."
            // script {
            //     def customerWorkspacePath = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_terraform"
            //     if (fileExists("${customerWorkspacePath}/terraform.tfstate")) {
            //        dir(customerWorkspacePath) {
            //            sh "terraform destroy -auto-approve"
            //        }
            //        echo "Đã destroy VM do lỗi."
            //     }
            // }
        } // Đóng failure
    } // Đóng post
} // Đóng pipeline