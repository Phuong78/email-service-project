// Jenkinsfile
pipeline {
    agent any // Hoặc label của agent node nếu bạn có agent riêng (Jenkins controller có Ansible và Terraform)

    environment {
    
    SSH_CREDENTIALS_ID = 'customer-vm-ssh-key' // ID bạn vừa tạo
        // Biến môi trường dùng chung
        AWS_REGION = 'us-east-1' // Hoặc vùng AWS của bạn
        // Đường dẫn đến thư mục chứa code Terraform mẫu cho VM khách hàng TRÊN JENKINS SERVER
        // Jenkins sẽ copy code từ đây vào workspace của job cho mỗi khách hàng
        TERRAFORM_CUSTOMER_TEMPLATE_PATH = "./terraform_customer_vm_template"
    ANSIBLE_PLAYBOOKS_PATH = "./ansible_playbooks"

        // AMI ID cho máy chủ khách hàng (có thể lấy từ Global Tool Configuration hoặc đặt ở đây)
        // Nên là AMI Ubuntu gốc, Ansible sẽ cài đặt mọi thứ
        CUSTOMER_VM_AMI_ID = 'ami-053b0d53c279acc90' // THAY THẾ BẰNG AMI UBUNTU GỐC MỚI NHẤT CHO VÙNG CỦA BẠN
        CUSTOMER_VM_INSTANCE_TYPE = 't2.micro'
        CUSTOMER_VM_KEY_PAIR_NAME = 'nguyenp-key-pair' // THAY THẾ
        CUSTOMER_VM_SUBNET_ID = 'subnet-0b49e3eae1288df2f' // THAY THẾ bằng Public Subnet ID của bạn

        // Thông tin NFS Server (lấy từ output Terraform chính hoặc nhập tay)
        NFS_SERVER_IP = "54.163.128.67" // THAY THẾ bằng IP public của NFS server
        NFS_SHARE_PATH = "/srv/nfs/shared_mail_data" // Đường dẫn share trên NFS Server

        // Thông tin Nagios Server (lấy từ output Terraform chính hoặc nhập tay)
        NAGIOS_SERVER_PRIVATE_IP = "10.0.1.172" // THAY THẾ bằng IP private của Nagios server
                                                          // (Ví dụ: 10.0.x.x, xem trong AWS Console hoặc output Terraform)
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
                    // Tạo thư mục làm việc riêng cho khách hàng này trong workspace của job
                    // Ví dụ: workspace/FPT_terraform, workspace/FPT_ansible_vars
                    def customerWorkspacePath = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_terraform"
                    sh "rm -rf ${customerWorkspacePath}" // Xóa thư mục cũ nếu có
                    sh "mkdir -p ${customerWorkspacePath}"
                    // Copy code Terraform mẫu vào workspace của khách hàng
                    sh "cp -R ${env.TERRAFORM_CUSTOMER_TEMPLATE_PATH}/* ${customerWorkspacePath}/"

                    // Tạo file biến terraform.tfvars cho khách hàng
                    // Jenkins sẽ điền các giá trị từ parameters và environment vào đây
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
                        // Chạy Terraform
                        sh "terraform init"
                        sh "terraform plan -out=tfplan"
                        // Cần có bước duyệt thủ công ở đây cho production
                        // input message: "Xác nhận tạo máy chủ cho ${params.CUSTOMER_NAME}?", submitter: "admins"
                        sh "terraform apply -auto-approve tfplan"

                        // Lấy IP của máy chủ vừa tạo
                        // Cách 1: Đọc trực tiếp từ output JSON (nếu Terraform > 0.12)
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
steps {
        withCredentials([sshUserPrivateKey(credentialsId: env.SSH_CREDENTIALS_ID, keyFileVariable: 'ANSIBLE_SSH_KEY_FILE')]) {
            script {
                // ... (các bước chuẩn bị khác) ...
                def inventoryContent = """
                [mail_server_customer]
                ${env.CUSTOMER_VM_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${ANSIBLE_SSH_KEY_FILE} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
                """
                def ansibleInventoryFile = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_inventory.ini"
                writeFile file: ansibleInventoryFile, text: inventoryContent

                dir(env.ANSIBLE_PLAYBOOKS_PATH) {
                   sh """
                   ansible-playbook -i ${ansibleInventoryFile} setup_mail_server.yml \
                       -e "customer_domain=${params.CUSTOMER_DOMAIN}" \
                       # ... (các extra vars khác) ...
                   """
                }

            when {
                expression { env.CUSTOMER_VM_PUBLIC_IP != null && env.CUSTOMER_VM_PUBLIC_IP != "" }
            }
            steps {
                script {
                    // Đợi một chút để SSH sẵn sàng trên máy chủ mới
                    sleep(60) // 60 giây

                    // Tạo file inventory tạm thời cho Ansible
                    // Hoặc truyền IP qua --extra-vars và dùng inventory động
                    def inventoryContent = """
                    [mail_server_customer]
                    ${env.CUSTOMER_VM_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/nguyenp-key-pair.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
                    """
                    // QUAN TRỌNG: Thay /path/to/your/private_key.pem bằng đường dẫn thực tế đến private key trên Jenkins server
                    // Hoặc tốt hơn là dùng Jenkins Credentials Binding cho SSH key
                    // Ví dụ: ~/.ssh/nguyenp-key-pair.pem
                    def ansibleInventoryFile = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_inventory.ini"
                    writeFile file: ansibleInventoryFile, text: inventoryContent

                    // Gọi Ansible playbook để cấu hình mail server
                    // Ví dụ: playbook tên là setup_mail_server.yml
                    // Cần truyền các biến cần thiết cho Ansible (CUSTOMER_DOMAIN, CUSTOMER_EMAIL_USER, CUSTOMER_EMAIL_PASSWORD, NFS_SERVER_IP, ...)
                    dir(env.ANSIBLE_PLAYBOOKS_PATH) {
                       sh """
                       ansible-playbook -i ${ansibleInventoryFile} setup_mail_server.yml \
                           -e "customer_domain=${params.CUSTOMER_DOMAIN}" \
                           -e "customer_email_user=${params.CUSTOMER_EMAIL_USER}" \
                           -e "customer_email_password='${params.CUSTOMER_EMAIL_PASSWORD}'" \
                           -e "nfs_server_ip=${env.NFS_SERVER_IP}" \
                           -e "nfs_share_path=${env.NFS_SHARE_PATH}" \
                           -e "nagios_server_private_ip=${env.NAGIOS_SERVER_PRIVATE_IP}" \
                           -e "target_host_private_ip=${env.CUSTOMER_VM_PRIVATE_IP}" \
                           -e "target_host_public_ip=${env.CUSTOMER_VM_PUBLIC_IP}"
                       """
                       // LƯU Ý: Cần đảm bảo playbook setup_mail_server.yml của bạn xử lý các biến này
                       // và thực hiện các tác vụ: cài Postfix, Dovecot, tạo user, mount NFS, cài Nagios client (NRPE) trỏ về NAGIOS_SERVER_PRIVATE_IP
                    }
                    echo "Đã cấu hình máy chủ cho ${params.CUSTOMER_NAME} bằng Ansible."
                }
            }
        }

        // stage('4. Cập nhật Nagios Server') {
        //     when {
        //         expression { env.CUSTOMER_VM_PUBLIC_IP != null && env.CUSTOMER_VM_PUBLIC_IP != "" }
        //     }
        //     steps {
        //         script {
        //             // Gọi một Ansible playbook khác (hoặc script) để thêm host mới này vào Nagios Server
        //             // Playbook này sẽ chạy trên Nagios Server (hoặc trên Jenkins và SSH vào Nagios)
        //             // Cần truyền thông tin của máy chủ khách hàng mới (hostname, IP) cho Nagios
        //             echo "Đang cập nhật Nagios Server..."
        //             // Ví dụ:
        //             // dir(env.ANSIBLE_PLAYBOOKS_PATH) {
        //             //    sh """
        //             //    ansible-playbook -i ${env.NAGIOS_SERVER_PRIVATE_IP}, update_nagios_config.yml \
        //             //        -e "new_host_name=${params.CUSTOMER_NAME}-mail" \
        //             //        -e "new_host_address=${env.CUSTOMER_VM_PRIVATE_IP}"
        //             //    """
        //             // }
        //             echo "Đã gửi yêu cầu cập nhật Nagios Server."
        //         }
        //     }
        // }

        // stage('5. Thông báo Kết quả cho n8n') {
        //     steps {
        //         script {
        //             // Gọi webhook của n8n để thông báo kết quả (thành công/thất bại)
        //             // def n8nWebhookUrl = "URL_WEBHOOK_N8N_CUA_BAN"
        //             // def payload = """
        //             // {
        //             //   "customerName": "${params.CUSTOMER_NAME}",
        //             //   "status": "success",
        //             //   "vmIp": "${env.CUSTOMER_VM_PUBLIC_IP}"
        //             // }
        //             // """
        //             // sh "curl -X POST -H 'Content-Type: application/json' -d '${payload}' ${n8nWebhookUrl}"
        //             echo "Đã thông báo cho n8n."
        //         }
        //     }
        // }
    }

    post {
        always {
            echo 'Hoàn thành pipeline onboarding khách hàng.'
            // Dọn dẹp workspace nếu cần
            // cleanWs()
        }
        success {
            echo "Pipeline cho ${params.CUSTOMER_NAME} hoàn thành thành công."
        }
        failure {
            echo "Pipeline cho ${params.CUSTOMER_NAME} thất bại."
            // (Tùy chọn) Chạy một playbook Terraform để destroy VM nếu tạo thất bại ở bước Ansible
            // script {
            //     def customerWorkspacePath = "${env.WORKSPACE}/${params.CUSTOMER_NAME}_terraform"
            //     if (fileExists("${customerWorkspacePath}/terraform.tfstate")) {
            //        dir(customerWorkspacePath) {
            //            sh "terraform destroy -auto-approve"
            //        }
            //        echo "Đã destroy VM do lỗi."
            //     }
            // }
            }
        }
    }
