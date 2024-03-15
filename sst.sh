#!/bin/bash
ln -sf ~/new.sh /usr/local/bin/sst
ip_address() {
    ipv4_address=$(curl -s ipv4.ip.sb)
    ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
}
break_end() {
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
}
isValidAlphaNumber()
{
    result="$(echo $1 | sed 's/[^[:alnum:]]//g')"   #替换非字母数字为空格
    #$()等价``，因此上句等价于result=`echo $1 | sed 's/[^[:alnum:]]//g'`
    #[:alnum:]等价于0-9A-Za-z中的一个字符，[[:alnum:]]是字母数字集，而[^[:alnum:]]表示除了所有字母数字外的任一字符
    if [ "$result" == "$1" ]
    then
        return 1        #novalid
    else 
        return 0        #valid
    fi
}

create_tmux(){
    while true; do
        read -p "输入tmux窗口名: " tmux_name
            result="$(echo $tmux_name | sed 's/[^[:alnum:]]//g')"   #替换非字母数字为空格
            #$()等价``，因此上句等价于result=`echo $1 | sed 's/[^[:alnum:]]//g'`
            #[:alnum:]等价于0-9A-Za-z中的一个字符，[[:alnum:]]是字母数字集，而[^[:alnum:]]表示除了所有字母数字外的任一字符
        if [ "$result" != "$tmux_name" ]
        then
            echo "名称只能包含数字或字母"       #notvalid
        else 
            break      #isvalid
        fi
    done
        tmux new-session -s $tmux_name -n editor -d
        tmux has-session -t $tmux_name 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "tmux窗口已创建"
            tmux send-keys -t $tmux_name "$1" C-m
	        echo "启动命令已发送"
	        read -p "是否进入tmux会话(y/n)" go_tmux
	        case $go_tmux in
		    y|Y)
			    tmux attach -t $tmux_name
			    ;;
		    *)
			    sst
            esac
        else
            echo "tmux窗口创建失败"
            fi
}
deltmux(){
                echo "选择要关闭的${1}对应的tmux会话"
                  echo "------------------------------------"

                  sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
                  
                  if [ -z "$sessions" ]; then
                      echo "没有找到任何 tmux 会话。"
                      read -p "按任意键继续..." -n 1
                      break # 如果没有会话，退出循环
                  fi

                  # 将会话名称放入数组中
                  mapfile -t sessions_arr <<< "$sessions"

                  # 显示所有会话供用户选择
                  for i in "${!sessions_arr[@]}"; do
                      echo "$((i+1)). ${sessions_arr[$i]}"
                  done

                  echo "------------------------"
                  echo "0. 退出"
                  read -p "请输入你的选择（数字）: " choice

                  if [[ $choice -eq 0 ]]; then
                      sst
                  fi

                  index=$((choice-1))

                  if [[ $index -ge 0 && $index -lt ${#sessions_arr[@]} ]]; then
                      session_name="${sessions_arr[$index]}"
                      tmux send-keys -t $session_name "stop" C-m
                      for second in {1..60}; do
                        clear
                        echo "stop命令已发送"
                        echo "============================================================================================="
                        tmux capture-pane -pt $session_name |grep -v '^$'|tail -n 3
                        echo "============================================================================================="
                        echo "等待服务关闭中... $second s"
                        sleep 1s
                        doesend=$(tmux capture-pane -pt $session_name |grep -E "Goodbye|bye")
                        if [[ "$doesend" != "" ]]
                            then
                                break
                        fi
                        done
                      if [[ "$doesend" != "" ]]

                        then
                        clear
                        echo "=================tmux最后输出信息================================================================="
                        tmux capture-pane -pt $session_name |tail -n 10
                        echo "================================================================================================="
                        read -p "请确认是否已完全关闭(Y/N):" isoff
                            case $isoff in
                            y|Y)
                                 tmux kill-session -t "$session_name"
                                 tmux has-session -t $session_name 2>/dev/null
                                if [ $? -eq 0 ]; then
                                    echo "删除失败！"
                                else
                                    break_end
                        fi
                                 ;;
                            n|N)
                                read -p "是否进入tmux会话手动处理(y/n)" to_tmux
                                 case $to_tmux in
		                            y|Y)
			                        tmux attach -t $session_name
			                        ;;
		                            *)
			                            sst
                                    esac
                                ;;
                            esac

                       
                        else
                            clear
                            echo "关闭超时!!!"
                            read -p "是否进入tmux会话手动处理(y/n)" goto_tmux
                                case $goto_tmux in
		                            y|Y)
			                        tmux attach -t $session_name
			                        ;;
		                            *)
			                            sst
                                    esac
                        fi
                  else
                      echo "无效的选择，请重新输入。"
                      sleep 2
                  fi
}
while true; do
  clear

  echo -e "SST服务器一键脚本工具"
  echo "------------------------"
  echo "1.服务端/Velocity管理?"
  echo "------------------------"
  echo "00. 系统信息"
  echo "0. 退出脚本"
  read -p "请输入你的选择: " choice

  case $choice in
    1)
      while true; do
        clear
        echo "---------服务端---------"
        echo "1.管理服务端"
        echo "--------Velocity--------"
        echo "2.管理Velocity"
        echo "------------------------"
        echo "0. 返回主菜单"
        read -p "请输入你的选择: " sub_choice

        case $sub_choice in
          1)
            while true; do
              clear
              echo "-----------------------------"
              echo "1.启动服务端"
              echo "2.关闭服务端"
              echo "-----------------------------"
              echo "0.返回主菜单"
              read -p "请输入你的选择: " server_management

              case $server_management in
                1)
                  clear
                  echo "请选择服务端版本"
                  echo "================="
                  cd /zhitai/SunshineTown/Server
                  serversVersion=($(ls -d 1.*.*)) # 修正
                  declare -a serverfile
                  declare -a serverVersionReord
                  ServerFileIndex=0
                  for i in "${!serversVersion[@]}"; do
                    echo "-------- ${serversVersion[i]} --------"
                    cd "/zhitai/SunshineTown/Server/${serversVersion[i]}"
                    TheServer=($(ls))
                    for j in "${!Theserver[@]}"; do
                      serverfile[ServerFileIndex]="${Theserver[j]}"
                      serverVersionReord[ServerFileIndex]="${serversVersion[i]}"
                      ServerFileIndex=$(($ServerFileIndex+1))
                      echo "$((i+1)). ${Theserver[$j]}"
                      done
                  done
                    read -p "请选择服务端: " server_indexs
                    let server_indexs=server_indexs-1
                    if [[ $server_indexs -ge 0 && $server_indexs -lt ${#serverfile[@]} ]]; then
                      create_tmux "cd /zhitai/SunshineTown/Server/${serverVersionReord[$server_indexs]}/${serverfile[$server_indexs]} && mcstart" # 创建tmux窗口传入启动命令

                    else
                      echo "无效的选择"
                    fi
                  ;;
                2)
                               deltmux 服务端
                               break
                  ;;
                0)
                  break
                  ;;
              esac
            done
            ;;
			2)
			 while true; do
              clear
              echo "-----------------------------"
              echo "1.启动Velocity"
              echo "2.关闭Velocity"
              echo "-----------------------------"
              echo "0.返回主菜单"
              read -p "请输入你的选择: " Velocity_management
			    case $Velocity_management in
                1)
                  clear
                  echo "请选择服务端"
                  echo "================="
                  velocity=($(cd /zhitai/SunshineTown/Velocity &&ls -d vc-*)) # 保存服务器列表为数组
                  for i in "${!velocity[@]}"; do
                    echo "$((i+1)). ${velocity[i]}"
                  done
                  read -p "请输入服务端编号: " velocity_index
                  let velocity_index=velocity_index-1 # 数组索引从0开始
                  
                  if [[ $velocity_index -ge 0 && $velocity_index -lt ${#velocity[@]} ]]; then
                    velocity_name=${velocity[$velocity_index]}
                    create_tmux "cd /zhitai/SunshineTown/Velocity/$velocity_name && bash start.sh"
                    
                  else
                    echo "无效的选择"
                  fi
                  ;;
                2)
                  clear
                        deltmux Velocity
                        break
                  ;;
                0)
                  break
                  ;;
              esac
            done
            ;;
          0)
            break
            ;;
        esac
      done
      ;;
    0)
      break
      ;;
    00)
        clear
    # 函数: 获取IPv4和IPv6地址
    ip_address

    if [ "$(uname -m)" == "x86_64" ]; then
      cpu_info=$(cat /proc/cpuinfo | grep 'model name' | uniq | sed -e 's/model name[[:space:]]*: //')
    else
      cpu_info=$(lscpu | grep 'BIOS Model name' | awk -F': ' '{print $2}' | sed 's/^[ \t]*//')
    fi

    cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
    cpu_usage_percent=$(printf "%.2f" "$cpu_usage")%

    cpu_cores=$(nproc)

    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

    country=$(curl -s ipinfo.io/country)
    city=$(curl -s ipinfo.io/city)

    isp_info=$(curl -s ipinfo.io/org)

    cpu_arch=$(uname -m)

    hostname=$(hostname)

    kernel_version=$(uname -r)

    congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
    queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # 尝试使用 lsb_release 获取系统信息
    os_info=$(lsb_release -ds 2>/dev/null)

    # 如果 lsb_release 命令失败，则尝试其他方法
    if [ -z "$os_info" ]; then
      # 检查常见的发行文件
      if [ -f "/etc/os-release" ]; then
        os_info=$(source /etc/os-release && echo "$PRETTY_NAME")
      elif [ -f "/etc/debian_version" ]; then
        os_info="Debian $(cat /etc/debian_version)"
      elif [ -f "/etc/redhat-release" ]; then
        os_info=$(cat /etc/redhat-release)
      else
        os_info="Unknown"
      fi
    fi

    output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
        NR > 2 { rx_total += $2; tx_total += $10 }
        END {
            rx_units = "Bytes";
            tx_units = "Bytes";
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "KB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "MB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "GB"; }

            if (tx_total > 1024) { tx_total /= 1024; tx_units = "KB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "MB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "GB"; }

            printf("总接收: %.2f %s\n总发送: %.2f %s\n", rx_total, rx_units, tx_total, tx_units);
        }' /proc/net/dev)


    current_time=$(date "+%Y-%m-%d %I:%M %p")


    swap_used=$(free -m | awk 'NR==3{print $3}')
    swap_total=$(free -m | awk 'NR==3{print $2}')

    if [ "$swap_total" -eq 0 ]; then
        swap_percentage=0
    else
        swap_percentage=$((swap_used * 100 / swap_total))
    fi

    swap_info="${swap_used}MB/${swap_total}MB (${swap_percentage}%)"

    runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

    echo ""
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名: $hostname"
    echo "运营商: $isp_info"
    echo "------------------------"
    echo "系统版本: $os_info"
    echo "Linux版本: $kernel_version"
    echo "------------------------"
    echo "CPU架构: $cpu_arch"
    echo "CPU型号: $cpu_info"
    echo "CPU核心数: $cpu_cores"
    echo "------------------------"
    echo "CPU占用: $cpu_usage_percent"
    echo "物理内存: $mem_info"
    echo "虚拟内存: $swap_info"
    echo "硬盘占用: $disk_info"
    echo "------------------------"
    echo "$output"
    echo "------------------------"
    echo "网络拥堵算法: $congestion_algorithm $queue_algorithm"
    echo "------------------------"
    echo "公网IPv4地址: $ipv4_address"
    echo "公网IPv6地址: $ipv6_address"
    echo "------------------------"
    echo "地理位置: $country $city"
    echo "系统时间: $current_time"
    echo "------------------------"
    echo "系统运行时长: $runtime"
    echo
    break_end
    ;;
    
  esac
done
